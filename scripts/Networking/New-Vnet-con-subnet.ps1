#############################################################################################################################################
##                                                                                                                                         ##
##    .Objeto: Creación de una Vnet con subredes en un grupo de recursos                                                                   ##
##    .Ejemplo:                                                                                                                            ##
##    $vNetName = 'GVA-PL-CON-GEN-VNET-01'                                                                                                 ##
##    $resourceGroupName = 'RG_GVA_GEN_CON_01'                                                                                             ##
##    $AddressPrefix = @('10.10.0.0/16')                                                                                                   ##
##    $subnet01Name = 'subnet_gateway'                                                                                                     ##
##    $subnet01AddressPrefix = '10.10.1.0/24'                                                                                              ##
##    .Salida: Mostrar el listado de Vnet del grupo de recursos                                                                            ##
##    .Autor: Dimas Ferrandis Gonzalvo                                                                                                     ##
##    .Versión: 1.0                                                                                                                        ##
##    .Fecha última modificación:                                                                                                          ##
##                                                                                                                                         ##
#############################################################################################################################################


# Importación de módulos requeridos
Import-Module -Name Az.Accounts
Import-Module -Name Az.Resources
Import-Module -Name Az.Network

# Se modifica el protocolo tls a la versión admitida.
$TLS12Protocol = [System.Net.SecurityProtocolType] 'Ssl3 , Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol

#Autenticación
$credenciales = Get-Credential

# Inicia sesión en tu cuenta de Azure
Connect-AzAccount -Credential $credenciales

#Parámetros de entrada
param (
    [Parameter(Mandatory = $true)]
    [string]$vNetName,
    [Parameter(Mandatory = $true)]
    [string]$resourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$AddressPrefix,
    [Parameter(Mandatory = $true)]
    [string]$subnet01Name,
    [Parameter(Mandatory = $true)]
    [string]$subnet01AddressPrefix
)

#Variables
$location = 'West Europe'

#Create new Azure Virtual Network Subnet configuration
$subnet01 = New-AzVirtualNetworkSubnetConfig -Name $subnet01Name -AddressPrefix $subnet01AddressPrefix

#Create new Azure Virtual Network with above subnet configuration
New-AzVirtualNetwork -Name $vNetName -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix $AddressPrefix -Subnet $subnet01

#Get existing Azure Virtual Network information
$azvNet = Get-AzVirtualNetwork -Name $vNetName -ResourceGroupName $resourceGroupName
Add-AzVirtualNetworkSubnetConfig -Name $subnet01Name -AddressPrefix $subnet01AddressPrefix -VirtualNetwork $azvNet 
