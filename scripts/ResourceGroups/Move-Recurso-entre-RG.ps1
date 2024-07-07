#############################################################################################################################################
##                                                                                                                                         ##
##    .Objeto: Mover un recursos desde un grupo de recursos hacia otro grupo de recursos                                                   ##
##    .Descripción:                                                                                                                        ##
##    Mover un recurso entre grupo de recursos                                                                                             ##  
##    .Ejemplo                                                                                                                             ##
##    Parametro Name - Especifica el nombre del recurso a mover                                                                            ##
##    Parameter Subscription - Especifica el nombre de la suscripción donde se encuentra el recurso                                        ##
##    Parameter grupos de recursos - Especifica el grupo de recursos de destino                                                            ##
##    .Salida: Mostrar el grupo de recursos donde se ha movido el recurso                                                                  ##
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

# Parámetros de entrada
param (
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string]$subscripcion,
    [string]$destination_rg

)


# Seleccionamis la suscripción donde está el recurso a mover
Select-AzSubscription -SubscriptionName $subscription

# Almacenamos el recurso a mover en una variable
$resources = Get-AzResource -Name $Name

# Muestra el valor del ResoureID por pantalla
 $resources.ResourceId

 # Mueve el recurso al grupo de recursos de destino
 Move-AzResource -DestinationResourceGroupName $destination_rg -ResourceId $resources.ResourceId

# Muestra una lista de los recursos en el grupo de recursos de destino
 Get-AzResource -ResourceGroupName $destination_rg
