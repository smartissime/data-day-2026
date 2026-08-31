<#
  ARCFODEV09 - Unified Developer Environment (UDE) Dynamics 365 F&O
  Creation via appel direct de l'API BAP, avec propriete "macroRegion".
  ---------------------------------------------------------------------------
  Pourquoi REST et pas PowerShell : le module Microsoft.PowerApps.Administration
  .PowerShell est fige en 2.0.217 (30/03/2026), anterieur au deploiement mondial
  du provisionnement par macro region. Il n'expose aucun parametre -MacroRegion
  et ne peut donc pas satisfaire l'API -> 400 MacroRegionRequired.

  Configuration retenue, copiee de l'environnement test-th (fonctionnel) :
    location = canada | macroRegion = the-americas | azureRegion = canadacentral

  USAGE
    1) .\New-ARCFODEV01-REST.ps1 -ListMacroRegions   # enumere les valeurs valides
    2) renseigner $MacroRegion ci-dessous
    3) .\New-ARCFODEV01-REST.ps1 -DryRun             # affiche le JSON sans rien creer
    4) .\New-ARCFODEV01-REST.ps1                     # creation reelle

  SI L'AUTHENTIFICATION AZ ECHOUE (MFA / acces conditionnel) :
    Connect-AzAccount -AuthScope "https://api.bap.microsoft.com/"
    ... ou contourner Az completement :
    .\New-ARCFODEV.ps1 -UsePowerAppsSession -ListMacroRegions
    .\New-ARCFODEV.ps1 -AccessToken "eyJ0..." -ListMacroRegions

  SI WAM ECHOUE ("A window handle must be configured") :
    le script desactive le broker et bascule seul en device code ;
    forcer explicitement avec -UseDeviceCode.

  A executer dans une NOUVELLE fenetre PowerShell 5.1 (la precedente porte
  encore un Set-StrictMode residuel).
#>

[CmdletBinding()]
param(
    [switch]$ListMacroRegions,
    [switch]$DryRun,
    [switch]$UsePowerAppsSession,
    [switch]$UseDeviceCode,
    [string]$AccessToken
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- Parametres ---------------------------------------------------------------
# Valeurs alignees sur l'environnement test-th, deja provisionne avec succes
# sur ce tenant : configuration prouvee, pas de valeur devinee.
$MacroRegion  = 'the-americas'        # confirme dans test-th.json
# /!\ macroRegion et location sont EXCLUSIFS ("AmbiguousLocationSpecification").
#     Tant que $MacroRegion est renseigne, $Location n'est PAS envoye : la
#     plateforme choisit le datacenter dans la macro region, guidee par le hint.
$Location     = 'canada'
$AzureRegion  = 'canadacentral'      # envoye comme properties.azureRegionHint
$DisplayName  = 'ARCFODEVTHIERRY'
$DomainName   = 'arcfodevTHIERRY'          # unique mondialement, minuscules
$Sku          = 'Sandbox'
$Template     = 'D365_FinOps_Finance'
$BaseLanguage = 1036                  # 1033 = anglais, 1036 = francais

# /!\ IRREVERSIBLE : la devise de base ne peut plus etre modifiee apres creation.
#     USD par defaut (coherent avec un environnement anglophone + donnees demo
#     Contoso). Bascule sur 'CAD' ici si la comptabilite doit etre canadienne.
$Currency     = 'USD'

$DevTools     = $true
$DemoData     = $true

$ApiVersion   = '2021-04-01'
$BapRoot      = 'https://api.bap.microsoft.com'
$Resource     = 'https://api.bap.microsoft.com/'

# --- Jeton d'acces ------------------------------------------------------------
# Trois sources possibles, par ordre de preference :
#   1. -AccessToken '...'      : jeton colle a la main (F12 dans le PPAC)
#   2. -UsePowerAppsSession    : reutilise la session Add-PowerAppsAccount
#   3. defaut                  : Az.Accounts, avec -AuthScope si MFA/acces conditionnel

function ConvertTo-PlainToken {
    param($Value)
    if ($Value -is [System.Security.SecureString]) {
        return [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Value))
    }
    return [string]$Value
}

function Get-TokenFromAz {
    param([string]$ResourceUrl)

    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        Write-Host 'Installation de Az.Accounts...' -ForegroundColor Yellow
        Install-Module -Name Az.Accounts -Scope CurrentUser -Force -AllowClobber
    }
    Import-Module Az.Accounts -ErrorAction Stop

    # -AsPlainText n'existe qu'a partir d'Az.Accounts 2.17 : on teste, on ne devine pas.
    $supportsPlain = (Get-Command Get-AzAccessToken).Parameters.ContainsKey('AsPlainText')

    $fetch = {
        if ($supportsPlain) { Get-AzAccessToken -ResourceUrl $ResourceUrl -AsPlainText }
        else { ConvertTo-PlainToken ((Get-AzAccessToken -ResourceUrl $ResourceUrl).Token) }
    }

    # WAM (broker Windows) exige un handle de fenetre, indisponible dans une
    # console PowerShell 5.1 -> on le desactive pour ce processus.
    try {
        Update-AzConfig -EnableLoginByWam $false -Scope Process -WarningAction SilentlyContinue | Out-Null
    } catch {
        Write-Verbose 'Update-AzConfig -EnableLoginByWam indisponible sur cette version d Az.Accounts.'
    }

    function Invoke-AzLogin {
        param([string]$Scope, [switch]$DeviceCode)
        if ($DeviceCode) {
            Connect-AzAccount -AuthScope $Scope -UseDeviceAuthentication | Out-Null
        } else {
            try {
                Connect-AzAccount -AuthScope $Scope | Out-Null
            } catch {
                # 'A window handle must be configured' = WAM sans fenetre parente.
                if ($_.Exception.Message -match 'window handle|WAM|broker|InteractiveBrowserCredential') {
                    Write-Warning 'Navigateur/broker indisponible, bascule sur le flux device code.'
                    Connect-AzAccount -AuthScope $Scope -UseDeviceAuthentication | Out-Null
                } else { throw }
            }
        }
    }

    # Un contexte peut exister tout en pointant vers un cache vide (echec de
    # connexion precedent) : on verifie qu'un compte y est reellement associe.
    $ctx = Get-AzContext
    if (-not $ctx -or -not $ctx.Account) {
        Write-Warning 'Contexte Az absent ou invalide, nettoyage puis reconnexion.'
        Disconnect-AzAccount -ErrorAction SilentlyContinue | Out-Null
        Clear-AzContext -Force -ErrorAction SilentlyContinue | Out-Null
        Invoke-AzLogin -Scope $ResourceUrl -DeviceCode:$UseDeviceCode
    }

    try {
        return & $fetch
    } catch {
        # Cas classique : MFA / acces conditionnel -> il faut un consentement
        # interactif pour CETTE audience precise.
        $m = $_.Exception.Message
        $needsLogin = $m -match 'User interaction is required|interactive|conditional access|multi-factor' `
                   -or $m -match 'CredentialUnavailable|SharedTokenCache|No accounts were found|not found in the cache'
        if ($needsLogin) {
            Write-Warning "Jeton indisponible pour $ResourceUrl - nettoyage du cache et reconnexion."
            Disconnect-AzAccount -ErrorAction SilentlyContinue | Out-Null
            Clear-AzContext -Force -ErrorAction SilentlyContinue | Out-Null
            Invoke-AzLogin -Scope $ResourceUrl -DeviceCode:$UseDeviceCode
            return & $fetch
        }
        throw   # toute autre erreur remonte telle quelle, sans masquage
    }
}

function Get-TokenFromPowerAppsSession {
    Import-Module Microsoft.PowerApps.Administration.PowerShell -ErrorAction Stop -WarningAction SilentlyContinue
    if (-not $global:currentSession -or -not $global:currentSession.loggedIn) {
        Add-PowerAppsAccount -Endpoint prod | Out-Null
    }
    $tokens = $global:currentSession.resourceTokens
    if (-not $tokens) { throw 'Session PowerApps sans resourceTokens. Utilise -AccessToken.' }

    Write-Host 'Audiences disponibles dans la session PowerApps :' -ForegroundColor Cyan
    $tokens.Keys | ForEach-Object { Write-Host "  $_" }

    $key = $tokens.Keys | Where-Object { $_ -match 'bap' } | Select-Object -First 1
    if (-not $key) { $key = $tokens.Keys | Where-Object { $_ -match 'powerapps' } | Select-Object -First 1 }
    if (-not $key) { throw 'Aucune audience BAP exploitable. Utilise -AccessToken.' }

    Write-Host "Audience retenue : $key" -ForegroundColor Green
    return ConvertTo-PlainToken $tokens[$key].accessToken
}

if ($AccessToken) {
    $token = $AccessToken -replace '^Bearer\s+', ''
    Write-Host 'Jeton fourni manuellement.' -ForegroundColor Green
}
elseif ($UsePowerAppsSession) {
    $token = Get-TokenFromPowerAppsSession
}
else {
    $token = Get-TokenFromAz -ResourceUrl $Resource
}

$headers = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }

# --- Construction du payload --------------------------------------------------
# Ce que le service nous a appris, erreur apres erreur :
#   * objet racine      = EnvironmentDefinition -> accepte macroRegion
#   * objet imbrique    = EnvironmentProperties -> refuse macroRegion
#   * 'azureRegion' n'existe sur aucun des deux ; le nom reel est
#     vraisemblablement 'azureRegionHint', dans properties.
#
# On ne devine plus : chaque champ optionnel dispose d'une liste de candidats
# (emplacement + nom), essayes dans l'ordre jusqu'a acceptation, avec abandon
# propre du champ si aucun ne passe. macroRegion, lui, est obligatoire.

# Champs neutralises en cours de route par les regles d'exclusivite du service.
$Suppressed = New-Object System.Collections.Generic.HashSet[string]

$Fields = [ordered]@{
    macroRegion = @{
        value      = $MacroRegion
        candidates = @(
            @{ path = 'root';       name = 'macroRegion' },
            @{ path = 'properties'; name = 'macroRegion' }
        )
        index = 0
    }
    azureRegion = @{
        value      = $AzureRegion
        candidates = @(
            @{ path = 'properties'; name = 'azureRegionHint' },
            @{ path = 'root';       name = 'azureRegionHint' },
            @{ path = 'properties'; name = 'azureRegion'     },
            @{ path = 'omit';       name = 'azureRegion'     }
        )
        index = 0
    }
}

function New-EnvironmentBody {
    param([string]$MacroOverride)

    $parameters = @()
    if ($DevTools) { $parameters += 'DevToolsEnabled=true' }
    if ($DemoData) { $parameters += 'DemoDataEnabled=true' }

    $props = [ordered]@{
        displayName    = $DisplayName
        environmentSku = $Sku
        databaseType   = 'CommonDataService'
    }
    $root = [ordered]@{}

    # Exclusivite : location n'est envoye QUE si aucune macro region n'est definie.
    $macroActive = -not [string]::IsNullOrWhiteSpace($MacroRegion) -or -not [string]::IsNullOrWhiteSpace($MacroOverride)
    if (-not $macroActive -and -not $Suppressed.Contains('location') -and $Location) {
        $root['location'] = $Location
    }

    foreach ($key in @($Fields.Keys)) {
        $f = $Fields[$key]
        $val = if ($key -eq 'macroRegion' -and $MacroOverride) { $MacroOverride } else { $f.value }
        if ([string]::IsNullOrWhiteSpace($val)) { continue }

        $c = $f.candidates[$f.index]
        if ($Suppressed.Contains($c.name)) { continue }
        switch ($c.path) {
            'root'       { $root[$c.name]  = $val }
            'properties' { $props[$c.name] = $val }
            'omit'       { }
        }
    }

    $props['linkedEnvironmentMetadata'] = [ordered]@{
        baseLanguage = $BaseLanguage
        currency     = @{ code = $Currency }
        domainName   = $DomainName
        templates    = @($Template)
        templateMetadata = @{
            PostProvisioningPackages = @(
                [ordered]@{
                    applicationUniqueName = 'msdyn_FinanceAndOperationsProvisioningAppAnchor'
                    parameters            = ($parameters -join '|')
                }
            )
        }
    }

    $root['properties'] = $props
    return ($root | ConvertTo-Json -Depth 12)
}

# PowerShell 5.1 consomme lui-meme le flux de reponse pour composer son message
# d'erreur : le corps JSON se lit dans ErrorDetails, pas dans GetResponseStream().
function Read-ErrorBody {
    param($ErrorRecord)

    if ($ErrorRecord.ErrorDetails -and $ErrorRecord.ErrorDetails.Message) {
        return $ErrorRecord.ErrorDetails.Message
    }
    try {
        $stream = $ErrorRecord.Exception.Response.GetResponseStream()
        if ($stream -and $stream.CanRead) {
            $stream.Position = 0
            return (New-Object IO.StreamReader($stream)).ReadToEnd()
        }
    } catch { }
    return $ErrorRecord.Exception.Message
}

# Fait avancer le champ portant ce nom vers son candidat suivant.
# Retourne $true si une nouvelle tentative est possible.
function Step-Field {
    param([string]$MemberName)

    foreach ($key in @($Fields.Keys)) {
        $f = $Fields[$key]
        if ($f.candidates[$f.index].name -ne $MemberName) { continue }

        if ($f.index -ge $f.candidates.Count - 1) {
            Write-Warning "'$MemberName' : plus aucun candidat disponible."
            return $false
        }
        $f.index++
        $next = $f.candidates[$f.index]
        if ($next.path -eq 'omit') {
            Write-Warning "'$MemberName' refuse partout : le champ est retire du payload."
        } else {
            Write-Warning "'$MemberName' refuse -> nouvel essai en '$($next.path).$($next.name)'."
        }
        return $true
    }
    return $false
}

$uri = "$BapRoot/providers/Microsoft.BusinessAppPlatform/environments?api-version=$ApiVersion"

# --- Mode 1 : enumeration des macro regions valides ---------------------------
if ($ListMacroRegions) {
    Write-Host 'Sonde de validation (aucun environnement ne sera cree)...' -ForegroundColor Cyan
    try {
        Invoke-RestMethod -Method Post -Uri $uri -Headers $headers `
            -Body (New-EnvironmentBody -MacroOverride 'zzz-invalide') | Out-Null
        Write-Warning "Aucune erreur retournee - la sonde n'a pas fonctionne."
    } catch {
        Write-Host '--- Reponse du service ---' -ForegroundColor Yellow
        Write-Host (Read-ErrorBody $_)
    }
    return
}

# --- Mode 2 : creation --------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($MacroRegion)) { throw 'Renseigne $MacroRegion.' }

Write-Host '--- Payload initial ---' -ForegroundColor Cyan
Write-Host (New-EnvironmentBody)

if ($DryRun) { Write-Host 'DryRun : rien envoye.' -ForegroundColor Yellow; return }

Write-Host ''
Write-Host '=== Recapitulatif (les 3 premieres lignes sont DEFINITIVES) ===' -ForegroundColor Yellow
Write-Host "  Macro region : $MacroRegion"
Write-Host "  Region       : $Location / $AzureRegion"
Write-Host "  Devise       : $Currency"
Write-Host "  Nom          : $DisplayName  ($DomainName)"
Write-Host "  Langue       : $BaseLanguage"
Write-Host "  Template     : $Template"
Write-Host ''
if ((Read-Host 'Lancer la creation ? (o/N)') -notin @('o','O','y','Y')) { return }

$response = $null
$json     = $null

for ($attempt = 1; $attempt -le 8; $attempt++) {

    $json = New-EnvironmentBody

    try {
        $response = Invoke-WebRequest -Method Post -Uri $uri -Headers $headers `
                        -Body $json -UseBasicParsing
        break
    }
    catch {
        $detail = Read-ErrorBody $_

        if ($detail -match "Could not find member '([^']+)' on object of type '([^']+)'") {
            $member = $matches[1]
            Write-Host "[tentative $attempt] $member rejete par $($matches[2])" -ForegroundColor DarkYellow
            if (Step-Field -MemberName $member) { continue }
        }

        # Exclusivite mutuelle : "Cannot specify both X and Y".
        # macroRegion est le mode de provisionnement retenu : on garde macroRegion
        # et on neutralise l'autre champ.
        if ($detail -match 'Cannot specify both (\w+) and (\w+)') {
            $a = $matches[1]; $b = $matches[2]
            $victim = if ($a -eq 'macroRegion') { $b } else { $a }
            if (-not $Suppressed.Contains($victim)) {
                Write-Warning "[tentative $attempt] '$a' et '$b' sont exclusifs -> '$victim' retire du payload."
                [void]$Suppressed.Add($victim)
                continue
            }
        }

        Write-Host '--- Erreur ---' -ForegroundColor Red
        Write-Host $detail
        Write-Host '--- Payload envoye ---' -ForegroundColor DarkGray
        Write-Host $json
        throw "Creation refusee par le service (voir ci-dessus)."
    }
}

if (-not $response) { throw 'Aucune forme de payload acceptee apres 8 tentatives.' }

Write-Host ''
Write-Host "HTTP $($response.StatusCode) - requete acceptee" -ForegroundColor Green
Write-Host '--- Payload accepte ---' -ForegroundColor DarkGray
Write-Host $json

$opUri = $response.Headers['Location']
if (-not $opUri) { $opUri = $response.Headers['Operation-Location'] }

# --- Suivi --------------------------------------------------------------------
if (-not $opUri) {
    Write-Warning "Pas d'URL de suivi retournee ; verifie l'etat dans le PPAC."
    return
}

Write-Host "Suivi : $opUri"
$state = ''
do {
    Start-Sleep -Seconds 60
    try {
        $op    = Invoke-RestMethod -Method Get -Uri $opUri -Headers $headers
        $state = $op.properties.provisioningState
    } catch {
        Write-Warning "Lecture de l'etat impossible : $($_.Exception.Message)"
        break
    }
    Write-Host ("[{0:HH:mm}] Etat : {1}" -f (Get-Date), $state)
} while ($state -notin @('Succeeded','Failed'))

Write-Host "Etat final : $state" -ForegroundColor $(if ($state -eq 'Succeeded') { 'Green' } else { 'Red' })
Write-Host "L'application F&O continue de se deployer 1 a 3 h en arriere-plan."
Write-Host "Suis la progression dans le PPAC : Ressources > Applications Dynamics 365."