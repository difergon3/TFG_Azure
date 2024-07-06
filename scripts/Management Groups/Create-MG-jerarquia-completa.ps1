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

# Management group de la organización
$companyManagementGroupName, $companyManagementGroupGuid = GenerateManagementGroup -prefix "" -suffix $companyName

# Management groups de Nivel 2
$platformManagementGroupName, $platformManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_PL"
$landingZonesManagementGroupName, $landingZonesManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_LZ"


# Management groups de la Plataforma
$managementManagementGroupName, $managementManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_GE"
$connectivityManagementGroupName, $connectivityManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_CON"
$identityManagementGroupName, $identityManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_ID"


# Management groups de la Landing Zone
$corpProdManagementGroupName, $corpManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_CORP_PROD"
$corpTestManagementGroupName, $corpManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_CORP_TEST"
$migrateManagementGroupName, $migrateManagementGroupGuid = GenerateManagementGroup -prefix $companyName -suffix "_MIG"



# Suscripciones
$subNameManagement = Get-AzSubscription | Where-Object {$_.Name -like "*GVA*GE*"}
$subNameConnectivity = Get-AzSubscription | Where-Object {$_.Name -like "*GVA*CON*"}
$subNameIdentity = Get-AzSubscription | Where-Object {$_.Name -like "*GVA*ID*"}
$subNameMigrate = Get-AzSubscription | Where-Object {$_.Name -like "*GVA*MIG*"}
$subNameCorpProd = Get-AzSubscription | Where-Object {$_.Name -like "*CORP*PROD*"}
$subNameCorpTest = Get-AzSubscription | Where-Object {$_.Name -like "*CORP*TEST*"}


# Format, hora y color
Set-PSBreakpoint -Variable currenttime -Mode Read -Action {$global:currenttime = Get-Date -Format "dddd MM/dd/yyyy HH:mm"} | Out-Null 
$foregroundColor1 = "Green"
$foregroundColor2 = "Yellow"
$writeEmptyLine = "`n"
$writeSeperatorSpaces = " - "

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Crear management group de la organización
$companyParentGroup = New-AzManagementGroup -GroupName $companyManagementGroupGuid -DisplayName $companyManagementGroupName

Write-Host ($writeEmptyLine + "# Company management group $companyManagementGroupName created" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Crear management groups de Nivel 2

# Crear management group Plataforma
$platformParentGroup = New-AzManagementGroup -GroupName $platformManagementGroupGuid -DisplayName $platformManagementGroupName -ParentObject $companyParentGroup

# Crear management group Landing Zone
$landingZonesParentGroup = New-AzManagementGroup -GroupName $landingZonesManagementGroupGuid -DisplayName $landingZonesManagementGroupName -ParentObject $companyParentGroup


Write-Host ($writeEmptyLine + "# Top management groups $platformManagementGroupName, $landingZonesManagementGroupName created" + $writeSeperatorSpaces + $currentTime) -foregroundcolor $foregroundColor2 $writeEmptyLine

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Crear management groups de la Plataforma

# Crear management group de Gestión
New-AzManagementGroup -GroupName $managementManagementGroupGuid -DisplayName $managementManagementGroupName -ParentObject $platformParentGroup | Out-Null

# Crear management group de Conectividad
New-AzManagementGroup -GroupName $connectivityManagementGroupGuid -DisplayName $connectivityManagementGroupName -ParentObject $platformParentGroup | Out-Null

# Create management group de Identidad
New-AzManagementGroup -GroupName $identityManagementGroupGuid -DisplayName $identityManagementGroupName -ParentObject $platformParentGroup | Out-Null

Write-Host ($writeEmptyLine + "# Platform management groups $managementManagementGroupName, $connectivityManagementGroupName and $identityManagementGroupName created" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Crear management groups de la Landing Zone

# Crear management group Corportivo entorno producción
New-AzManagementGroup -GroupName $corpProdManagementGroupGuid -DisplayName $corpManagementGroupName -ParentObject $landingZonesParentGroup | Out-Null

# Crear management group Corportivo entorno test
New-AzManagementGroup -GroupName $corpTestManagementGroupGuid -DisplayName $corpManagementGroupName -ParentObject $landingZonesParentGroup | Out-Null

# Crear management group Migrate
New-AzManagementGroup -GroupName $migrateManagementGroupGuid -DisplayName $migrateManagementGroupName -ParentObject $landingZonesParentGroup | Out-Null


Write-Host ($writeEmptyLine + "# Landing Zones management groups created" + $writeSeperatorSpaces + $currentTime) -foregroundcolor $foregroundColor2 $writeEmptyLine

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


## Mover las suscripciones desde el Tenant Root Group al management groups apropiado si existe

# Mover Suscripción de Gestión
If($subNameManagement)
{
    New-AzManagementGroupSubscription -GroupId $managementManagementGroupGuid -SubscriptionId $subNameManagement.SubscriptionId | Out-Null
}

# Mover Suscripción de Conectividad
If($subNameConnectivity)
{
    New-AzManagementGroupSubscription -GroupId $connectivityManagementGroupGuid -SubscriptionId $subNameConnectivity.SubscriptionId | Out-Null
}

# Mover Suscripción de Identidad
If($subNameIdentity)
{
    New-AzManagementGroupSubscription -GroupId $identityManagementGroupGuid -SubscriptionId $subNameIdentity.SubscriptionId | Out-Null
}

# Mover Suscripción de Landing Zone Corporativo Producción
If($subNameCorpProd)
{
    New-AzManagementGroupSubscription -GroupId $corpManagementGroupGuid  -SubscriptionId $subNameCorpProd.SubscriptionId | Out-Null
}

# Mover Suscripción de Landing Zone Corporativo Producción
If($subNameCorpTest)
{
    New-AzManagementGroupSubscription -GroupId $corpManagementGroupGuid  -SubscriptionId $subNameCorpTest.SubscriptionId | Out-Null
}


Write-Host ($writeEmptyLine + "# Subscriptions moved to management groups" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Escribir Script completado

Write-Host ($writeEmptyLine + "# Script completed" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine 
