Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [System.String] $BaseUrl,

        [Parameter()]
        [System.UInt64] $SiteId = 1,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'

    )
    process {
        ImportSFModule -Name Citrix.Storefront;
        $stfDeployment = Get-STFDeployment -SiteId $SiteId -WarningAction SilentlyContinue;
        $featureclassinstances = $stfdeployment.FeatureClassInstances;
        $targetResource = @{
            BaseUrl = $stfDeployment.HostbaseUrl;
            SiteId = $stfDeployment.SiteId;
            Ensure = if (($stfDeployment) -and ($featureclassinstances)) { 'Present' } else { 'Absent' };
        }
        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [System.String] $BaseUrl,

        [Parameter()]
        [System.UInt64] $SiteId = 1,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        $targetResource = Get-TargetResource @PSBoundParameters;
        $inDesiredState = $true;

        if ($Ensure -ne $targetResource.Ensure) {
            Write-Verbose -Message ($localizedData.ClusterPropertyMismatch -f 'Ensure', $Ensure, $targetResource.Ensure);
            $inDesiredState = $false;
        }

        ## Only check all remaing properties if we're setting
        if ($Ensure -eq 'Present') {
            $properties = @('BaseUrl','SiteId');
            foreach ($property in $properties) {
                $propertyValue = (Get-Variable -Name $property).Value;
                if ($targetResource.$property -ne $propertyValue) {
                    Write-Verbose -Message ($localizedData.ClusterPropertyMismatch -f $property, $propertyValue, $targetResource.$property);
                    $inDesiredState = $false;
                }
            }
        }

        if ($inDesiredState) {
            Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $BaseUrl);
        }
        else {
            Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $BaseUrl);
        }
        return $inDesiredState;
    } #end process
} #end function Test-TargetResource


function Set-TargetResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String] $BaseUrl,

        [Parameter()]
        [System.UInt64] $SiteId = 1,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        $targetResource = Get-TargetResource @PSBoundParameters;

        if ($Ensure -eq 'Absent') {
            if ($targetResource.Ensure = 'Present') {
                ## Cluster exists, removing
                Write-Verbose -Message ($localizedData.RemovingStorefrontCluster -f $BaseUrl);
                [ref] $null = Clear-STFDeployment -SiteId $SiteId -Confirm:$false;
            }
        }
        elseif ($Ensure -eq 'Present') {
            if ($targetResource.Ensure -eq 'Present') {        
                Write-Verbose -Message ($localizedData.UpdatingStorefrontClusterUrl -f $BaseUrl);

                # There seems to be an issue, Set-STFDeployment doesn't set the new Base URL propberly
                #[ref] $null = Set-STFDeployment -SiteId $SiteId -HostBaseUrl $BaseUrl -Confirm:$false;

                # Load the Utilities and Cluster powershell
                $dsInstallProp = Get-ItemProperty -Path HKLM:\SOFTWARE\Citrix\DeliveryServicesManagement -Name InstallDir
                $dsInstallDir = $dsInstallProp.InstallDir
                Import-Module "$dsInstallDir\Cmdlets\UtilsModule.psm1" -Scope Global -Verbose:$false
                Import-Module "$dsInstallDir\Cmdlets\ClusterConfigurationModule.psm1" -Scope Global -Verbose:$false

                # Set the new address
                [ref] $null = Set-DSClusterAddress -NewHostBaseUrl $BaseUrl

            }
            else {
                $stfdeployment = Get-STFDeployment
                if (-not $stfdeployment.FeatureClassInstances)
                {
                    Write-Verbose -Message ($localizedData.RemovingStorefrontCluster -f $BaseUrl);
                    [ref] $null = Clear-STFDeployment -SiteId $SiteId -Confirm:$false;
                }     

                ## Cluster does not exist, creating
                Write-Verbose -Message ($localizedData.AddingStorefrontCluster -f $BaseUrl);
                [ref] $null = Add-STFDeployment -HostBaseUrl $BaseUrl -SiteId 1 -Confirm:$false;
            }
        }
        #
        #Clear-STFDeployment -SiteId
    } #end process
} #end function Set-TargetResource
