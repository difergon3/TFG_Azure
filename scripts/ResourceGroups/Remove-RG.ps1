#############################################################################################################################################
##                                                                                                                                         ##
##    .Objeto: Eliminar un grupo de recursos y todos los recursos asociados en Azure                                                       ##
##    .Ejemplo: Hay que ejecutar el script y solicitará los siguientes parámetros                                                          ##
##              Parameter Name - Indicar el nombre del grupo de recursos                                                                   ##
##              Parameter Id - Indicar el ID del grupo de recursos a eliminar                                                              ##
##    .Notas                                                                                                                               ##
##     Requiere el módulo Az.Resources                                                                                                     ##
##                                                                                                                                         ## 
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

param( 
    [Parameter(Mandatory = $true,ParameterSetName="byName")]
    [string]$Name,
    [Parameter(Mandatory = $true,ParameterSetName="byID")]
    [string]$Id
)


try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Force' = $null}
    
    if($PSCmdlet.ParameterSetName -eq "byID"){
        $cmdArgs.Add('ID',$Id)
        $Script:key = $Id
    }
    else{
        $cmdArgs.Add('Name',$Name)
        $Script:key = $Name
    }

    $null = Remove-AzResourceGroup @cmdArgs
    $rg = "Resource group $($Script:key) removed"

    if($Result) {
        $Result.ResultMessage = $rg 
    }
    else{
        Write-Output $rg
    }
}
catch{
    throw
}
finally{
}
