#############################################################################################################################################
##                                                                                                                                         ##
##    .Objeto: Creación del árbol con la estructura de los management groups en Azure                                                      ##
##    .Descripcion:                                                                                                                        ##
##    Crear el management group de la organización                                                                                         ##
##    Crear los management groups de primer nivel                                                                                          ##
##    Crear los management groups de la Plataforma                                                                                         ##
##    Crear los management groups de la Landing Zone                                                                                       ##
##    Mover las suscripciones desde el Tenant Root Group al management group que le corresponde                                            ##
##    .Salida: Mostrar el grupo de administración creado y el grupo de recursos asociado                                                   ##
##    .Autor: Dimas Ferrandis Gonzalvo                                                                                                     ##
##    .Versión: 1.0                                                                                                                        ##
##    .Fecha última modificación:                                                                                                          ##
##                                                                                                                                         ##
#############################################################################################################################################


# Importación de módulos requeridos
Import-Module -Name Az.Accounts
Import-Module -Name Az.Resources

# Se modifica el protocolo tls a la versión admitida.
$TLS12Protocol = [System.Net.SecurityProtocolType] 'Ssl3 , Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol

#Autenticación
$credenciales = Get-Credential

# Inicia sesión en tu cuenta de Azure
Connect-AzAccount -Credential $credenciales


## Función

function GenerateManagementGroup {
    param (
        [string]$prefix,
        [string]$suffix
    )

    $groupName = "MG_" + $prefix + $suffix + "_01"
    $groupGuid = New-Guid

    return $groupName, $groupGuid
}


## Variables

$companyName = "GVA"

# Company management group
$companyManagementGroupName, $companyManagementGroupGuid = GenerateManagementGroup -prefix "" -suffix $companyName

# Top management groups
$platformManagementGroupName, $platformManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_PL"
$landingZonesManagementGroupName, $landingZonesManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_LZ"


# Platform management groups
$managementManagementGroupName, $managementManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_GE"
$connectivityManagementGroupName, $connectivityManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_CON"
$identityManagementGroupName, $identityManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_ID"


# Landing zones management groups
$corpManagementGroupName, $corpManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_CORP_PROD"
$corpManagementGroupName, $corpManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_CORP_TEST"
$migrateManagementGroupName, $migrateManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_MIG"



# Subscriptions
$subNameManagement = Get-AzSubscription | Where-Object {$_.Name -like "*GVA*GE*"}
$subNameConnectivity = Get-AzSubscription | Where-Object {$_.Name -like "*GVA*CON*"}
$subNameIdentity = Get-AzSubscription | Where-Object {$_.Name -like "*GVA*ID*"}
$subNameMigrate = Get-AzSubscription | Where-Object {$_.Name -like "*GVA*MIG*"}
$subNameCorpProd = Get-AzSubscription | Where-Object {$_.Name -like "*CORP*PROD*"}
$subNameCorpTest = Get-AzSubscription | Where-Object {$_.Name -like "*CORP*TEST*"}


# Time, colors, and formatting
Set-PSBreakpoint -Variable currenttime -Mode Read -Action {$global:currenttime = Get-Date -Format "dddd MM/dd/yyyy HH:mm"} | Out-Null 
$foregroundColor1 = "Green"
$foregroundColor2 = "Yellow"
$writeEmptyLine = "`n"
$writeSeperatorSpaces = " - "

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Create Company management group
$companyParentGroup = New-AzManagementGroup -GroupName $companyManagementGroupGuid -DisplayName $companyManagementGroupName

Write-Host ($writeEmptyLine + "# Company management group $companyManagementGroupName created" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create Top management groups

# Create Platform management group
$platformParentGroup = New-AzManagementGroup -GroupName $platformManagementGroupGuid -DisplayName $platformManagementGroupName -ParentObject $companyParentGroup

# Create Landing Zones management group
$landingZonesParentGroup = New-AzManagementGroup -GroupName $landingZonesManagementGroupGuid -DisplayName $landingZonesManagementGroupName -ParentObject $companyParentGroup


Write-Host ($writeEmptyLine + "# Top management groups $platformManagementGroupName, $landingZonesManagementGroupName created" + $writeSeperatorSpaces + $currentTime) -foregroundcolor $foregroundColor2 $writeEmptyLine

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create Platform management groups

# Create Management management group
New-AzManagementGroup -GroupName $managementManagementGroupGuid -DisplayName $managementManagementGroupName -ParentObject $platformParentGroup | Out-Null

# Create Connectivity management group
New-AzManagementGroup -GroupName $connectivityManagementGroupGuid -DisplayName $connectivityManagementGroupName -ParentObject $platformParentGroup | Out-Null

# Create Identity management group
New-AzManagementGroup -GroupName $identityManagementGroupGuid -DisplayName $identityManagementGroupName -ParentObject $platformParentGroup | Out-Null

Write-Host ($writeEmptyLine + "# Platform management groups $managementManagementGroupName, $connectivityManagementGroupName and $identityManagementGroupName created" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create Landing Zones management groups

# Create Corp management group
New-AzManagementGroup -GroupName $corpManagementGroupGuid -DisplayName $corpManagementGroupName -ParentObject $landingZonesParentGroup | Out-Null

# Create Migrate management group
New-AzManagementGroup -GroupName $migrateManagementGroupGuid -DisplayName $migrateManagementGroupName -ParentObject $landingZonesParentGroup | Out-Null


Write-Host ($writeEmptyLine + "# Landing Zones management groups created" + $writeSeperatorSpaces + $currentTime) -foregroundcolor $foregroundColor2 $writeEmptyLine

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


## Move subscriptions from the tenant root group or previous group scope to the appropriate management groups if they are present

# Move Management subscription, if it exists
If($subNameManagement)
{
    New-AzManagementGroupSubscription -GroupId $managementManagementGroupGuid -SubscriptionId $subNameManagement.SubscriptionId | Out-Null
}

# Move Connectivity subscription, if it exists
If($subNameConnectivity)
{
    New-AzManagementGroupSubscription -GroupId $connectivityManagementGroupGuid -SubscriptionId $subNameConnectivity.SubscriptionId | Out-Null
}

# Move Identity subscription, if it exists
If($subNameIdentity)
{
    New-AzManagementGroupSubscription -GroupId $identityManagementGroupGuid -SubscriptionId $subNameIdentity.SubscriptionId | Out-Null
}

# Move Corp Production subscription, if it exists
If($subNameCorpProd)
{
    New-AzManagementGroupSubscription -GroupId $corpManagementGroupGuid  -SubscriptionId $subNameCorpProd.SubscriptionId | Out-Null
}

# Move Corp Test subscription, if it exists
If($subNameCorpTest)
{
    New-AzManagementGroupSubscription -GroupId $corpManagementGroupGuid  -SubscriptionId $subNameCorpTest.SubscriptionId | Out-Null
}


Write-Host ($writeEmptyLine + "# Subscriptions moved to management groups" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Write script completed

Write-Host ($writeEmptyLine + "# Script completed" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine 

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
