#############################################################################################################################################
##                                                                                                                                         ##
##    .Objeto: Creación de un grupo de recursos                                                                                            ##
##    .Entrada: Nombre del grupo de recursos a crear                                                                                       ##
##    .Salida: Mostrar el grupo de recursos asociado                                                                                       ##
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
param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

)


# Variables
$nombre_rg = "RG_GVA_${Name}_01"
$Localizacion = "West Europe"


#Autenticación
$credenciales = Get-Credential

# Inicia sesión en tu cuenta de Azure
Connect-AzAccount -Credential $credenciales



# Crear un grupo de recursos
try {
    New-AzResourceGroup -Name $nombre_rg -Location $Localizacion -Verbose
    Write-Output "Resource Group '$nombre_rg' creado correctamente en la región '$Localizacion'."
} catch {
    Write-Output "Error al crear el Resource Group: $_"
}
