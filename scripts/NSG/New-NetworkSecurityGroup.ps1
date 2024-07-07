#############################################################################################################################################
##                                                                                                                                         ##
##    .Objeto: Creación de un grupo de seguridad de red                                                                                    ##
##    .Descripción:                                                                                                                        ##
##    .Ejemplo                                                                                                                             ##
##    Parametro Name - Especifica el nombre del grupo de seguridad de red a crear                                                          ##
##    Parameter ResourceGroupName - Especifica el nombre del grupo de recursos                                                             ##
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

# Parámetros de entrada
param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName
)

# Variables
$Location="West Europe"

#Autenticación
$credenciales = Get-Credential

# Inicia sesión en tu cuenta de Azure
Connect-AzAccount -Credential $credenciales

# Crear el grupo de seguridad de red
try {
    New-AzNetworkSecurityGroup -Name $Name -ResourceGroupName $ResourceGroupName -Location $Location -Verbose
    Write-Output "NSG '$Name' creado correctamente en la región '$Localizacion'."
} catch {
    Write-Output "Error al crear el Grupo de Seguridad de red: $_"
}
