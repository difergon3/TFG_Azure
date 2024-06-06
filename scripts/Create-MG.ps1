#############################################################################################################################################
##                                                                                                                                         ##
##    .Objeto: Creación de los grupos de administración en una suscripción determinada                                                     ##
##    .Entrada: Funcionalidad o area del grupo de administración e identificador de la suscripción                                         ##
##    .Salida: Mostrar el grupo de administración creado                                                                                   ##
##    .Autor: Dimas Ferrandis Gonzalvo                                                                                                     ##
##    .Versión: 1.0                                                                                                                        ##
##    .Fecha última modificación:                                                                                                          ##
##                                                                                                                                         ##
#############################################################################################################################################


# Importación de módulos requeridos 
Import-Module -Name Az.Accounts
Import-Module -Name Az.Billing
Import-Module -Name Az.Resources

# Se modifica el protocolo tls a la versión admitida.
$TLS12Protocol = [System.Net.SecurityProtocolType] 'Ssl3 , Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol

# Parámetros de entrada
param (
    [Parameter(Mandatory = $true)]
    [string]$Funcionalidad
    [Parameter(Mandatory = $true)]
    [string]$subscriptionId
)

# Variables
$nombre_mg = "MG_GVA_${Funcionalidad}_01"
$DisplayName_mg = "MG_GVA_${Funcionalidad}_01"
$nombre_rg = "RG_GVA_${Funcionalidad}_01"
$Localizacion = "West Europe"

#Autenticación
$credenciales = Get-Credential

# Inicia sesión en tu cuenta de Azure
Connect-AzAccount -Credential $credenciales

# Crear un grupo de administración
try {
    New-AzManagementGroup -GroupId $nombre_mg -DisplayName $DisplayName_mg -Verbose
    Write-Output "Management Group '$nombre_mg' creado correctamente."
} catch {
    Write-Output "Error al crear el Management Group: $_"
}

# Asignar una suscripción a un grupo de administración
try {
    New-AzManagementGroupSubscription -GroupId $nombre_mg -SubscriptionId $subscriptionId -Verbose
    Write-Output "Suscripción '$subscriptionId' asignada al Management Group '$nombre_mg'."
} catch {
    Write-Output "Error al asignar la suscripción al Management Group: $_"
}
