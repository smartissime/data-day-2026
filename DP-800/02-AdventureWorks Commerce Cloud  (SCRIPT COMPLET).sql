/* ============================================================================
   FIL ROUGE DP-800 — "AdventureWorks Commerce Cloud"  (SCRIPT COMPLET)
   ============================================================================
   Base de départ : AdventureWorksLT2025 (schéma SalesLT) restaurée sur
   SQL Server 2025 (ou Azure SQL Database compatible SQL Server 2025).

   Ce script est organisé en 12 blocs = les 12 modules de la formation.
   Exécuter les blocs DANS L'ORDRE, jour après jour ; chaque bloc suppose les
   précédents déjà appliqués. Voir DP-800-Guide-Pas-a-Pas.txt pour le mode
   d'emploi détaillé de chaque étape (installation, dépannage, résultats
   attendus).

   AVANT DE COMMENCER, remplacer partout dans ce fichier :
     <VOTRE_RESSOURCE>   → le nom de votre ressource Azure OpenAI
                            (ex : https://mon-openai-dp800.openai.azure.com)
     <VOTRE_CLE_API>     → la clé API de cette ressource (portail Azure →
                            Clés et points de terminaison)
     <DEPLOIEMENT_EMBED> → le nom du déploiement du modèle d'embedding
                            (ex : embeddings-dp800)
     <DEPLOIEMENT_CHAT>  → le nom du déploiement du modèle de chat
                            (ex : chat-dp800)
   Ces 4 remplacements ne sont nécessaires qu'à partir du Module 9 (Jour 3).
   ============================================================================ */

/* ────────────────────────────────────────────────────────────────────────
   JOUR 1 — CONCEPTION ET DÉVELOPPEMENT DE BD
   ──────────────────────────────────────────────────────────────────────── */

/* === Module 1 — Objets de base de données ================================ */

-- Séquence pour un numéro de commande lisible métier
IF EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'OrderNumberSeq')
  DROP SEQUENCE SalesLT.OrderNumberSeq;
CREATE SEQUENCE SalesLT.OrderNumberSeq AS INT START WITH 100000 INCREMENT BY 1;

-- Colonne JSON pour les préférences client (canal, newsletter, tags)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('SalesLT.Customer') AND name = 'Preferences')
  ALTER TABLE SalesLT.Customer ADD Preferences NVARCHAR(MAX) NULL
    CONSTRAINT CK_Customer_Preferences CHECK (ISJSON(Preferences) = 1);

-- Table temporelle : historique des changements de profil client
IF OBJECT_ID('SalesLT.CustomerProfileHistory', 'U') IS NULL
BEGIN
  CREATE TABLE SalesLT.CustomerProfileHistory
  (
    CustomerID     INT NOT NULL,
    EmailAddress   NVARCHAR(50) NULL,
    Phone          NVARCHAR(25) NULL,
    Preferences    NVARCHAR(MAX) NULL,
    ValidFrom      DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo        DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    CONSTRAINT PK_CustomerProfileHistory PRIMARY KEY (CustomerID)
  ) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = SalesLT.CustomerProfileHistory_Archive));
END;

-- Alimenter la table temporelle avec l'état actuel des clients (une seule fois)
INSERT INTO SalesLT.CustomerProfileHistory (CustomerID, EmailAddress, Phone, Preferences)
SELECT CustomerID, EmailAddress, Phone, NULL
FROM SalesLT.Customer c
WHERE NOT EXISTS (SELECT 1 FROM SalesLT.CustomerProfileHistory h WHERE h.CustomerID = c.CustomerID);

-- Table de commande "moderne" partitionnée par année (démo conceptuelle)
IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'PF_OrderYear')
BEGIN
  CREATE PARTITION FUNCTION PF_OrderYear (DATE) AS RANGE RIGHT
    FOR VALUES ('2024-01-01', '2025-01-01', '2026-01-01');
  CREATE PARTITION SCHEME PS_OrderYear AS PARTITION PF_OrderYear ALL TO ([PRIMARY]);
END;

-- === Démonstration Module 1 (à exécuter ligne par ligne devant les participants) ===
UPDATE SalesLT.Customer SET EmailAddress = 'test.demo@example.com'
WHERE CustomerID = (SELECT MIN(CustomerID) FROM SalesLT.Customer);
SELECT * FROM SalesLT.CustomerProfileHistory_Archive;

-- Test volontaire de la contrainte JSON (doit ÉCHOUER) :
-- UPDATE SalesLT.Customer SET Preferences = 'texte-invalide' WHERE CustomerID = (SELECT MIN(CustomerID) FROM SalesLT.Customer);

UPDATE SalesLT.Customer SET Preferences = '{"channel":"email","newsletter":true}'
WHERE CustomerID = (SELECT MIN(CustomerID) FROM SalesLT.Customer);


/* === Module 2 — Programmabilité SQL ======================================= */

IF OBJECT_ID('SalesLT.vw_CustomerOrderSummary', 'V') IS NOT NULL DROP VIEW SalesLT.vw_CustomerOrderSummary;
GO
-- Vue : synthèse commande client (masque les jointures, calque de sécurité)
CREATE VIEW SalesLT.vw_CustomerOrderSummary AS
SELECT c.CustomerID, c.FirstName, c.LastName,
       COUNT(DISTINCT h.SalesOrderID) AS NbCommandes,
       SUM(d.LineTotal) AS TotalTTC
FROM SalesLT.Customer c
JOIN SalesLT.SalesOrderHeader h ON h.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderDetail d ON d.SalesOrderID = h.SalesOrderID
GROUP BY c.CustomerID, c.FirstName, c.LastName;
GO

IF OBJECT_ID('SalesLT.fn_CalculateLoyaltyPoints', 'FN') IS NOT NULL DROP FUNCTION SalesLT.fn_CalculateLoyaltyPoints;
GO
-- Fonction scalaire : points de fidélité (1 pt / 10 € dépensés)
CREATE FUNCTION SalesLT.fn_CalculateLoyaltyPoints(@Total MONEY)
RETURNS INT AS
BEGIN
  RETURN CAST(@Total / 10 AS INT);
END;
GO

IF OBJECT_ID('SalesLT.fn_GetTopProducts', 'IF') IS NOT NULL DROP FUNCTION SalesLT.fn_GetTopProducts;
GO
-- TVF inline : top N produits par chiffre d'affaires
CREATE FUNCTION SalesLT.fn_GetTopProducts(@TopN INT)
RETURNS TABLE AS RETURN
  SELECT TOP (@TopN) p.ProductID, p.Name, SUM(d.LineTotal) AS CA
  FROM SalesLT.Product p
  JOIN SalesLT.SalesOrderDetail d ON d.ProductID = p.ProductID
  GROUP BY p.ProductID, p.Name;
GO

IF OBJECT_ID('SalesLT.OrderAudit', 'U') IS NULL
  CREATE TABLE SalesLT.OrderAudit (SalesOrderID INT, ChangedAt DATETIME2, ChangedBy SYSNAME);
GO

IF OBJECT_ID('SalesLT.usp_PlaceOrder', 'P') IS NOT NULL DROP PROCEDURE SalesLT.usp_PlaceOrder;
GO
-- Procédure stockée : passage de commande (paramètres nommés, sortie)
CREATE PROCEDURE SalesLT.usp_PlaceOrder
  @CustomerID INT, @ProductID INT, @Qty SMALLINT,
  @NewOrderID INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO SalesLT.SalesOrderHeader (CustomerID, OrderDate, DueDate, Status)
    VALUES (@CustomerID, SYSUTCDATETIME(), DATEADD(DAY, 7, SYSUTCDATETIME()), 1);
    SET @NewOrderID = SCOPE_IDENTITY();
    INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice)
    SELECT @NewOrderID, @ProductID, @Qty, UnitPrice FROM SalesLT.Product WHERE ProductID = @ProductID;
    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
  END CATCH
END;
GO

IF OBJECT_ID('SalesLT.trg_Orders_Audit', 'TR') IS NOT NULL DROP TRIGGER SalesLT.trg_Orders_Audit;
GO
-- Déclencheur : audit des commandes
CREATE TRIGGER SalesLT.trg_Orders_Audit ON SalesLT.SalesOrderHeader AFTER INSERT AS
BEGIN
  INSERT INTO SalesLT.OrderAudit (SalesOrderID, ChangedAt, ChangedBy)
  SELECT SalesOrderID, SYSUTCDATETIME(), SUSER_SNAME() FROM inserted;
END;
GO

-- === Démonstration Module 2 ===
SELECT * FROM SalesLT.vw_CustomerOrderSummary;

DECLARE @NewOrderID INT;
EXEC SalesLT.usp_PlaceOrder @CustomerID = 1, @ProductID = 680, @Qty = 1, @NewOrderID = @NewOrderID OUTPUT;
SELECT @NewOrderID AS NouvelleCommande;
SELECT * FROM SalesLT.OrderAudit ORDER BY ChangedAt DESC;

-- Test volontaire d'échec (ProductID inexistant, doit lever une erreur et ne rien laisser d'incohérent) :
-- DECLARE @NewOrderID2 INT;
-- EXEC SalesLT.usp_PlaceOrder @CustomerID = 1, @ProductID = 999999, @Qty = 1, @NewOrderID = @NewOrderID2 OUTPUT;


/* === Module 3 — T-SQL avancé (1/2) : CTE, fenêtrage, JSON, regex ========== */

-- CTE récursif : arborescence des catégories de produits
WITH CategoryTree AS (
  SELECT ProductCategoryID, Name, ParentProductCategoryID, 0 AS Niveau
  FROM SalesLT.ProductCategory WHERE ParentProductCategoryID IS NULL
  UNION ALL
  SELECT c.ProductCategoryID, c.Name, c.ParentProductCategoryID, t.Niveau + 1
  FROM SalesLT.ProductCategory c JOIN CategoryTree t ON c.ParentProductCategoryID = t.ProductCategoryID
)
SELECT * FROM CategoryTree ORDER BY Niveau;

-- Fonction fenêtrée : total cumulé des ventes par date
SELECT h.OrderDate, d.LineTotal,
       SUM(d.LineTotal) OVER (ORDER BY h.OrderDate ROWS UNBOUNDED PRECEDING) AS CumulTotal
FROM SalesLT.SalesOrderHeader h JOIN SalesLT.SalesOrderDetail d ON d.SalesOrderID = h.SalesOrderID
ORDER BY h.OrderDate;

-- JSON : lecture des préférences client
SELECT CustomerID, JSON_VALUE(Preferences, '$.channel') AS Canal,
       JSON_VALUE(Preferences, '$.newsletter') AS Newsletter
FROM SalesLT.Customer WHERE Preferences IS NOT NULL;

-- Regex + fuzzy matching : rapprocher les noms de produits par motif
SELECT ProductID, Name FROM SalesLT.Product WHERE REGEXP_LIKE(Name, '^(Road|Mountain)-\d{3}');


/* === Module 4 — T-SQL avancé (2/2) : gestion d'erreurs + IA assistée ====== */

-- (gestion d'erreurs : voir TRY/CATCH dans usp_PlaceOrder ci-dessus — revoir la démo en direct)

-- Fichier d'instructions Copilot (livré à part, dans le dépôt Git du Module 7) :
--   .github/copilot-instructions.md → normes T-SQL de l'équipe Commerce Cloud
-- Connexion du serveur MCP SQL sur AdventureWorksLT2025 : démonstration live dans VS Code,
-- pas de script T-SQL associé (voir DP-800-Guide-Pas-a-Pas.txt, Module 4).


/* ────────────────────────────────────────────────────────────────────────
   JOUR 2 — SÉCURITÉ, OPTIMISATION, CI/CD
   ──────────────────────────────────────────────────────────────────────── */

/* === Module 5 — Sécurité des données ====================================== */

-- Chiffrement transparent (au repos) — nécessite un certificat maître de service déjà présent
-- (créé automatiquement à l'installation de SQL Server). Si l'instruction suivante échoue,
-- passer à la ligne suivante : ce n'est pas bloquant pour le reste de la démonstration.
ALTER DATABASE CURRENT SET ENCRYPTION ON;

-- Masquage dynamique des données
IF NOT EXISTS (SELECT 1 FROM sys.masked_columns WHERE name = 'EmailAddress')
  ALTER TABLE SalesLT.Customer ALTER COLUMN EmailAddress ADD MASKED WITH (FUNCTION = 'email()');
IF NOT EXISTS (SELECT 1 FROM sys.masked_columns WHERE name = 'Phone')
  ALTER TABLE SalesLT.Customer ALTER COLUMN Phone ADD MASKED WITH (FUNCTION = 'partial(2,"XXX-XXX-",2)');

-- Compte de démonstration pour visualiser le masquage sans droit UNMASK
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'commercial_demo')
  CREATE LOGIN commercial_demo WITH PASSWORD = 'Demo!2026azerty';
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'commercial_demo')
  CREATE USER commercial_demo FOR LOGIN commercial_demo;
GRANT SELECT ON SalesLT.Customer TO commercial_demo;
-- Démo : ouvrir une 2e connexion avec commercial_demo / Demo!2026azerty et comparer
-- SELECT CustomerID, EmailAddress, Phone FROM SalesLT.Customer; avec la connexion admin.

-- Sécurité au niveau des lignes : un commercial ne voit que ses clients
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Security')
  EXEC('CREATE SCHEMA Security');
GO
IF OBJECT_ID('Security.fn_SalesRepPredicate', 'IF') IS NOT NULL DROP FUNCTION Security.fn_SalesRepPredicate;
GO
CREATE FUNCTION Security.fn_SalesRepPredicate(@SalesPerson SYSNAME)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
  SELECT 1 AS fn_result WHERE @SalesPerson = USER_NAME() OR USER_NAME() IN ('dbo', 'commercial_demo');
GO
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'CustomerFilter')
  DROP SECURITY POLICY Security.CustomerFilter;
CREATE SECURITY POLICY Security.CustomerFilter
  ADD FILTER PREDICATE Security.fn_SalesRepPredicate(SalesPerson) ON SalesLT.Customer;
GO

-- Rôles et permissions par fonction
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'CommerceReadOnly')
  CREATE ROLE CommerceReadOnly;
GRANT SELECT ON SCHEMA::SalesLT TO CommerceReadOnly;

-- Audit — adapter le chemin selon l'OS : Windows ex. 'C:\SQLAudit\', Linux/conteneur ex. '/var/opt/mssql/audit/'
IF NOT EXISTS (SELECT 1 FROM sys.server_audits WHERE name = 'AdventureWorksAudit')
  CREATE SERVER AUDIT AdventureWorksAudit TO FILE (FILEPATH = 'C:\SQLAudit\');
ALTER SERVER AUDIT AdventureWorksAudit WITH (STATE = ON);
SELECT * FROM sys.dm_server_audit_status;


/* === Module 6 — Optimisation des performances ============================= */

ALTER DATABASE CURRENT SET QUERY_STORE = ON;

-- Index manquant détecté sur une requête lente (catalogue produit par catégorie + prix)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Product_Category_Price')
  CREATE NONCLUSTERED INDEX IX_Product_Category_Price
    ON SalesLT.Product (ProductCategoryID, ListPrice) INCLUDE (Name);

-- Mesure avant/après (SET STATISTICS TIME ON dans la fenêtre de requête)
SET STATISTICS TIME ON;
SELECT ProductID, Name FROM SalesLT.Product WHERE ProductCategoryID = 6 AND ListPrice < 500;
SET STATISTICS TIME OFF;

-- Démo interblocage : SESSION A puis SESSION B, dans DEUX fenêtres SSMS distinctes.
-- SESSION A : BEGIN TRAN; UPDATE SalesLT.Product SET ListPrice = ListPrice WHERE ProductID = 1;
-- SESSION B : BEGIN TRAN; UPDATE SalesLT.SalesOrderHeader SET Status = 1 WHERE SalesOrderID = 1;
-- SESSION A : UPDATE SalesLT.SalesOrderHeader SET Status = 1 WHERE SalesOrderID = 1;  -- reste bloqué
-- SESSION B : UPDATE SalesLT.Product SET ListPrice = ListPrice WHERE ProductID = 1;   -- déclenche l'erreur 1205
-- Puis, dans la session qui a "survécu" : COMMIT; ou ROLLBACK; pour libérer les verrous restants.


/* === Module 7 — CI/CD & projets SQL Database =============================== */

-- Ce module se déroule majoritairement HORS de SSMS (terminal + VS Code + GitHub).
-- Voir DP-800-Guide-Pas-a-Pas.txt, Module 7, pour la suite exacte de commandes :
--   dotnet new sqlproj -n AdventureWorksCommerceCloud
--   git init / add / commit / push
--   git checkout -b feature/stock-check → modifier usp_PlaceOrder → PR → build CI

-- AdventureWorksCommerceCloud.sqlproj (extrait, style SDK) :
-- <Project Sdk="Microsoft.Build.Sql/0.2.0">
--   <PropertyGroup><Name>AdventureWorksCommerceCloud</Name>
--     <DSP>Microsoft.Data.Tools.Schema.Sql.SqlAzureV12DatabaseSchemaProvider</DSP>
--   </PropertyGroup>
-- </Project>


/* === Module 8 — Intégration Azure =========================================== */

-- dab-config.json (voir le fichier complet dans DP-800-Guide-Pas-a-Pas.txt, Module 8) :
-- expose Product (lecture) et SalesOrderHeader (création + lecture) en REST + GraphQL.

-- Change Data Capture sur SalesOrderHeader (nécessite l'Agent SQL Server démarré)
EXEC sys.sp_cdc_enable_db;
EXEC sys.sp_cdc_enable_table @source_schema = 'SalesLT', @source_name = 'SalesOrderHeader', @role_name = NULL;

-- Vérifier le nom exact de la table de changement générée, puis interroger :
SELECT * FROM cdc.change_tables;
-- SELECT * FROM cdc.fn_cdc_get_all_changes_dbo_SalesOrderHeader(sys.fn_cdc_get_min_lsn('dbo_SalesOrderHeader'), sys.fn_cdc_get_max_lsn(), 'all');


/* ────────────────────────────────────────────────────────────────────────
   JOUR 3 — FONCTIONNALITÉS IA DANS LES BD
   ──────────────────────────────────────────────────────────────────────── */

/* === Préparatifs Jour 3 : identifiants pour les appels de modèles externes === */

-- Nécessaire une seule fois par base pour pouvoir créer des DATABASE SCOPED CREDENTIAL.
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
  CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'UnMotDePasseSolide!2026';

-- Autoriser SQL Server à appeler des points de terminaison REST externes
EXEC sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE;

-- Identifiant vers votre ressource Azure OpenAI (remplacer les deux valeurs)
IF EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = 'https://<VOTRE_RESSOURCE>.openai.azure.com')
  DROP DATABASE SCOPED CREDENTIAL [https://<VOTRE_RESSOURCE>.openai.azure.com];
CREATE DATABASE SCOPED CREDENTIAL [https://<VOTRE_RESSOURCE>.openai.azure.com]
  WITH IDENTITY = 'HTTPEndpointHeaders', SECRET = '{"api-key":"<VOTRE_CLE_API>"}';


/* === Module 9 — Modèles et embeddings ======================================= */

IF EXISTS (SELECT 1 FROM sys.external_models WHERE name = 'AzureOpenAIEmbedding')
  DROP EXTERNAL MODEL AzureOpenAIEmbedding;
CREATE EXTERNAL MODEL AzureOpenAIEmbedding
WITH (
  LOCATION = 'https://<VOTRE_RESSOURCE>.openai.azure.com/openai/deployments/<DEPLOIEMENT_EMBED>',
  API_FORMAT = 'Azure OpenAI',
  MODEL_TYPE = EMBEDDINGS,
  MODEL = 'text-embedding-3-small',
  CREDENTIAL = [https://<VOTRE_RESSOURCE>.openai.azure.com]
);

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('SalesLT.Product') AND name = 'DescriptionEmbedding')
  ALTER TABLE SalesLT.Product ADD DescriptionEmbedding VECTOR(1536) NULL;

UPDATE SalesLT.Product
SET DescriptionEmbedding = AI_GENERATE_EMBEDDINGS(Name + ' — ' + ISNULL(Description, '') USE MODEL AzureOpenAIEmbedding)
WHERE DescriptionEmbedding IS NULL;

-- Vérification (doit renvoyer 0)
SELECT COUNT(*) AS ProduitsSansEmbedding FROM SalesLT.Product WHERE DescriptionEmbedding IS NULL;


/* === Module 10 — Recherche intelligente ===================================== */

-- Index de recherche en texte intégral
IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs WHERE name = 'ftCatalog')
  CREATE FULLTEXT CATALOG ftCatalog AS DEFAULT;
IF NOT EXISTS (SELECT 1 FROM sys.fulltext_indexes WHERE object_id = OBJECT_ID('SalesLT.Product'))
  CREATE FULLTEXT INDEX ON SalesLT.Product(Name, Description) KEY INDEX PK_Product_ProductID
    ON ftCatalog WITH CHANGE_TRACKING AUTO;

-- Recherche en texte intégral (formes fléchies)
SELECT ProductID, Name FROM SalesLT.Product WHERE FREETEXT((Name, Description), 'léger compétition');

-- Recherche vectorielle : produits similaires à une requête libre
DECLARE @QueryVector VECTOR(1536) = AI_GENERATE_EMBEDDINGS('vélo de route léger pour compétition' USE MODEL AzureOpenAIEmbedding);
SELECT TOP 5 ProductID, Name, VECTOR_DISTANCE('cosine', DescriptionEmbedding, @QueryVector) AS Distance
FROM SalesLT.Product ORDER BY Distance;
GO

-- Recherche hybride : fusion RRF entre texte intégral et vectoriel
IF OBJECT_ID('SalesLT.usp_HybridProductSearch', 'P') IS NOT NULL DROP PROCEDURE SalesLT.usp_HybridProductSearch;
GO
CREATE PROCEDURE SalesLT.usp_HybridProductSearch @Query NVARCHAR(200), @K INT = 60 AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @QVec VECTOR(1536) = AI_GENERATE_EMBEDDINGS(@Query USE MODEL AzureOpenAIEmbedding);

  ;WITH FullTextRank AS (
    SELECT ProductID, ROW_NUMBER() OVER (ORDER BY [KEY_TBL].[RANK] DESC) AS Rang
    FROM SalesLT.Product AS p
    INNER JOIN CONTAINSTABLE(SalesLT.Product, (Name, Description), @Query) AS KEY_TBL
      ON p.ProductID = KEY_TBL.[KEY]
  ),
  VectorRank AS (
    SELECT TOP 50 ProductID,
           ROW_NUMBER() OVER (ORDER BY VECTOR_DISTANCE('cosine', DescriptionEmbedding, @QVec)) AS Rang
    FROM SalesLT.Product
  )
  SELECT p.ProductID, p.Name, p.ListPrice,
         ISNULL(1.0 / (@K + f.Rang), 0) + ISNULL(1.0 / (@K + v.Rang), 0) AS ScoreRRF
  FROM SalesLT.Product p
  LEFT JOIN FullTextRank f ON f.ProductID = p.ProductID
  LEFT JOIN VectorRank v ON v.ProductID = p.ProductID
  WHERE f.ProductID IS NOT NULL OR v.ProductID IS NOT NULL
  ORDER BY ScoreRRF DESC;
END;
GO

-- Démo : comparer les trois approches sur la même question
EXEC SalesLT.usp_HybridProductSearch @Query = N'vélo léger pour compétition';


/* === Module 11 — RAG (Retrieval-Augmented Generation) ======================= */

IF EXISTS (SELECT 1 FROM sys.external_models WHERE name = 'AzureOpenAIChat')
  DROP EXTERNAL MODEL AzureOpenAIChat;
CREATE EXTERNAL MODEL AzureOpenAIChat
WITH (
  LOCATION = 'https://<VOTRE_RESSOURCE>.openai.azure.com/openai/deployments/<DEPLOIEMENT_CHAT>',
  API_FORMAT = 'Azure OpenAI', MODEL_TYPE = CHAT, MODEL = 'gpt-4o-mini',
  CREDENTIAL = [https://<VOTRE_RESSOURCE>.openai.azure.com]
);
GO

IF OBJECT_ID('SalesLT.usp_AskProductAssistant', 'P') IS NOT NULL DROP PROCEDURE SalesLT.usp_AskProductAssistant;
GO
CREATE PROCEDURE SalesLT.usp_AskProductAssistant @Question NVARCHAR(400) AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @QVec VECTOR(1536) = AI_GENERATE_EMBEDDINGS(@Question USE MODEL AzureOpenAIEmbedding);
  DECLARE @Context NVARCHAR(MAX) = (
    SELECT TOP 5 Name, ListPrice, Description
    FROM SalesLT.Product ORDER BY VECTOR_DISTANCE('cosine', DescriptionEmbedding, @QVec)
    FOR JSON PATH
  );
  DECLARE @Prompt NVARCHAR(MAX) = (
    SELECT
      N'Tu es un assistant produit. Réponds UNIQUEMENT à partir du catalogue JSON suivant, ' +
      N'et dis explicitement que tu ne sais pas si l''information n''y figure pas. ' +
      N'Catalogue : ' + @Context + N' Question du client : ' + @Question AS [messages.0.content]
  );
  DECLARE @Response NVARCHAR(MAX), @RetCode INT;
  EXEC @RetCode = sp_invoke_external_rest_endpoint
       @url = 'https://<VOTRE_RESSOURCE>.openai.azure.com/openai/deployments/<DEPLOIEMENT_CHAT>/chat/completions?api-version=2024-06-01',
       @method = 'POST',
       @credential = [https://<VOTRE_RESSOURCE>.openai.azure.com],
       @payload = @Prompt,
       @response = @Response OUTPUT;
  SELECT @RetCode AS CodeRetour, @Response AS Reponse;
END;
GO

-- Comparaison pédagogique : d'abord un appel SANS contexte dans Azure OpenAI Studio (hors script),
-- puis avec la procédure ci-dessous (ancrée sur le vrai catalogue) :
EXEC SalesLT.usp_AskProductAssistant @Question = N'Avez-vous le vélo de route XR-500 en stock, à quel prix ?';


/* === Module 12 — Cas d'usage intégré & révision ============================== */

-- Vérifications rapides avant la démo finale
SELECT TOP 1 * FROM SalesLT.vw_CustomerOrderSummary;
SELECT COUNT(*) AS ProduitsSansEmbedding FROM SalesLT.Product WHERE DescriptionEmbedding IS NULL; -- doit être 0

-- Démo de bout en bout : "Assistant client AdventureWorks Commerce Cloud"
-- Combine : recherche hybride (M10) + génération ancrée (M11) + catalogue sécurisé et
-- audité (M5-M6) + exposé via Data API Builder (M8) + schéma versionné (M7) + fondations
-- du Jour 1 (M1-M4).
EXEC SalesLT.usp_AskProductAssistant @Question = N'Quel vélo de route recommandez-vous sous 1500 € avec de bons avis ?';

-- Variante libre pour la démonstration participative :
-- EXEC SalesLT.usp_AskProductAssistant @Question = N'<question proposée par un participant>';


/* ============================================================================
   NETTOYAGE (optionnel, entre deux sessions de formation)
   ============================================================================
   DROP SECURITY POLICY IF EXISTS Security.CustomerFilter;
   DROP FUNCTION IF EXISTS Security.fn_SalesRepPredicate;
   DROP USER IF EXISTS commercial_demo;
   DROP LOGIN IF EXISTS commercial_demo;
   -- puis restaurer à nouveau AdventureWorksLT2025 depuis le fichier .bak d'origine
   ============================================================================ */
