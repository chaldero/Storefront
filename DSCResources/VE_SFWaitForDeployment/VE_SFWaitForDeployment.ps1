Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Url,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ExistingStorefrontServer,

        [Parameter()]
        [System.UInt64] $RetryIntervalSec = 30,

        [Parameter()]
        [System.UInt32] $RetryCount = 20
    )
    process {
        [ref] $null = ImportSFModule -Name Citrix.Storefront;

        # No point testing availability here in Get-TargetResource!
        $targetResource = @{
            Url = $Url;
            ExistingStorefrontServer = $ExistingControllerName;
            RetryIntervalSec = $RetryIntervalSec;
            RetryCount = $RetryCount;
        }

        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Url,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ExistingStorefrontServer,

        [Parameter()]
        [System.UInt64] $RetryIntervalSec = 30,

        [Parameter()]
        [System.UInt32] $RetryCount = 20
    )
    process {

        $scriptBlock = {
            try {
                Import-Module Citrix.Storefront
                $SFDeployment = (Get-STFDeployment).HostbaseUrl
            }
            catch {}

            return $SFDeployment.HostbaseUrl
        }
        $SFDeploymentUrl =  Invoke-Command -ComputerName $ExistingStorefrontServer -ScriptBlock $scriptBlock
        if ($SFDeploymentUrl -like $Url) {
            Write-Verbose -Message "Storefront Deployment exists on server $ExistingStorefrontServer with URL: $Url" 
            return $true
        }
        Write-Verbose -Message "Storefront Deployment doesn't exist on server $ExistingStorefrontServer with URL: $Url"
        return $false
    } #end process
} #end function Test-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Url,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ExistingStorefrontServer,

        [Parameter()]
        [System.UInt64] $RetryIntervalSec = 30,

        [Parameter()]
        [System.UInt32] $RetryCount = 20
    )
    process {

        for ($count = 0; $count -lt $RetryCount; $count++) {

            $scriptBlock = {
                try {
                    Import-Module Citrix.Storefront
                    $SFDeployment = (Get-STFDeployment).HostbaseUrl
                }
                catch {}

                return $SFDeployment.HostbaseUrl
            }
            $SFDeploymentUrl =  Invoke-Command -ComputerName $ExistingStorefrontServer -ScriptBlock $scriptBlock
            
            if ($SFDeploymentUrl -like $Url) {
                break;
            }
            else {
                Start-Sleep -Seconds $RetryIntervalSec;
            }

        }


    } #end process
} #end function Set-TargetResource
