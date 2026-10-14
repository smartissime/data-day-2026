-- Copyright ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
-- All rights reserved.
-- NordShopDB : script de création et chargement
-- Fil rouge des 3 jours de formation DP-600 (Data Day / ARCHIA365)
-- Exécuter sur SQL Server 2019+ ou Azure SQL. Import des CSV via BULK INSERT ou l'assistant d'import.

CREATE DATABASE NordShopDB;
GO
USE NordShopDB;
GO

CREATE SCHEMA staging;
GO
CREATE SCHEMA dbo;
GO
CREATE SCHEMA dim;
GO
CREATE SCHEMA fact;
GO

-- ============ Tables sources (staging, miroir des CSV) ============
CREATE TABLE staging.Clients (
    ClientID        VARCHAR(10)     NOT NULL PRIMARY KEY,
    Prenom          NVARCHAR(50),
    Nom             NVARCHAR(50),
    Email           NVARCHAR(100),
    Ville           NVARCHAR(50),
    Region          NVARCHAR(50),
    Segment         NVARCHAR(30),
    DateInscription DATE
);
GO

CREATE TABLE staging.Produits (
    ProductKey      VARCHAR(10)     NOT NULL PRIMARY KEY,
    NomProduit      NVARCHAR(100),
    Categorie       NVARCHAR(50),
    SousCategorie   NVARCHAR(50),
    PrixUnitaire    DECIMAL(10,2),
    CoutUnitaire    DECIMAL(10,2),
    Fournisseur     NVARCHAR(50)
);
GO

CREATE TABLE staging.Commandes (
    OrderID         VARCHAR(10)     NOT NULL,
    LineNumber      INT             NOT NULL,
    ClientID        VARCHAR(10),
    ProductKey      VARCHAR(10),
    DateCommande    DATE,
    Quantite        INT,
    PrixUnitaire    DECIMAL(10,2),
    Remise          DECIMAL(5,2),
    Region          NVARCHAR(50),
    Statut          NVARCHAR(20),
    Canal           NVARCHAR(20),
    CONSTRAINT PK_Commandes PRIMARY KEY (OrderID, LineNumber)
);
GO

-- Import (adapter le chemin local du serveur SQL) :
-- BULK INSERT staging.Clients   FROM 'C:\NordShop\clients.csv'   WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE='65001');
-- BULK INSERT staging.Produits  FROM 'C:\NordShop\produits.csv'  WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE='65001');
-- BULK INSERT staging.Commandes FROM 'C:\NordShop\commandes.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE='65001');

-- ============ Schéma en étoile (Jour 2, module 7 & 8) ============
CREATE TABLE dim.Client (
    ClientKey       INT IDENTITY(1,1) PRIMARY KEY,
    ClientID        VARCHAR(10) NOT NULL,
    Prenom          NVARCHAR(50),
    Nom             NVARCHAR(50),
    Email           NVARCHAR(100),
    Ville           NVARCHAR(50),
    Region          NVARCHAR(50),
    Segment         NVARCHAR(30),
    DateDebutValidite DATE DEFAULT '2000-01-01',
    DateFinValidite   DATE NULL,
    EstActuel         BIT DEFAULT 1          -- support SCD Type 2 (démo module 7/8)
);
GO

CREATE TABLE dim.Produit (
    ProductKey      INT IDENTITY(1,1) PRIMARY KEY,
    ProductID       VARCHAR(10) NOT NULL,
    NomProduit      NVARCHAR(100),
    Categorie       NVARCHAR(50),
    SousCategorie   NVARCHAR(50),
    Fournisseur     NVARCHAR(50)
);
GO

CREATE TABLE dim.Date (
    DateKey     INT PRIMARY KEY,       -- format YYYYMMDD
    Date        DATE NOT NULL,
    Annee       INT, Mois INT, Jour INT,
    NomMois     NVARCHAR(20), Trimestre INT
);
GO

CREATE TABLE fact.Ventes (
    VenteKey        BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderID         VARCHAR(10),
    LineNumber      INT,
    ClientKey       INT REFERENCES dim.Client(ClientKey),
    ProductKey      INT REFERENCES dim.Produit(ProductKey),
    DateKey         INT REFERENCES dim.Date(DateKey),
    Quantite        INT,
    PrixUnitaire    DECIMAL(10,2),
    Remise          DECIMAL(5,2),
    Montant         AS (Quantite * PrixUnitaire * (1 - Remise)) PERSISTED,
    Statut          NVARCHAR(20),
    Canal           NVARCHAR(20)
);
GO

-- ============ Objets de démonstration (Jour 1 : sécurité) ============
-- DENY SELECT ON dbo.Employes(Salaire) TO [Equipe_Ventes]  -- exemple de sécurité colonne (créer table Employes si besoin)

-- ============ Objets de démonstration (Jour 2, module 8 : vues, procédures, MERGE) ============
CREATE VIEW dbo.vw_VentesRegion AS
SELECT c.Region, p.Categorie, SUM(f.Montant) AS ChiffreAffaires
FROM fact.Ventes f
JOIN dim.Client c ON f.ClientKey = c.ClientKey
JOIN dim.Produit p ON f.ProductKey = p.ProductKey
GROUP BY c.Region, p.Categorie;
GO

CREATE PROCEDURE dbo.ChargerVentes @DateCommande DATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Exemple pédagogique : charge fact.Ventes pour une date donnée depuis staging.Commandes
    INSERT INTO fact.Ventes (OrderID, LineNumber, ClientKey, ProductKey, DateKey, Quantite, PrixUnitaire, Remise, Statut, Canal)
    SELECT s.OrderID, s.LineNumber, dc.ClientKey, dp.ProductKey,
           CONVERT(INT, CONVERT(VARCHAR(8), s.DateCommande, 112)),
           s.Quantite, s.PrixUnitaire, s.Remise, s.Statut, s.Canal
    FROM staging.Commandes s
    JOIN dim.Client dc ON dc.ClientID = s.ClientID AND dc.EstActuel = 1
    JOIN dim.Produit dp ON dp.ProductID = s.ProductKey
    WHERE s.DateCommande = @DateCommande;
END;
GO

-- Exemple de MERGE pour charger dim.Client (upsert, module 8)
-- MERGE dim.Client AS target
-- USING staging.Clients AS source ON target.ClientID = source.ClientID AND target.EstActuel = 1
-- WHEN MATCHED AND target.Region <> source.Region THEN
--     UPDATE SET EstActuel = 0, DateFinValidite = GETDATE()
-- WHEN NOT MATCHED THEN
--     INSERT (ClientID, Prenom, Nom, Email, Ville, Region, Segment)
--     VALUES (source.ClientID, source.Prenom, source.Nom, source.Email, source.Ville, source.Region, source.Segment);
