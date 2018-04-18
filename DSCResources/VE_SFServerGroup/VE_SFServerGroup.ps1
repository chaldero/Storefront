Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [System.String] $AuthorizerHostName,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        [ref] $null = ImportSFModule -Name Citrix.Storefront;

        # Check if SF Server is already part of Storefront cluster
        $clusterMembers = (Invoke-Command -ComputerName $AuthorizerHostName -ScriptBlock {Get-STFServerGroup}).ClusterMembers

        $targetResource = @{
            AuthorizerHostName = $AuthorizerHostName
            Ensure = if ($clusterMembers -match $env:COMPUTERNAME)  { 'Present' } else { 'Absent' };
        } 

        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [System.String] $AuthorizerHostName,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        $targetResource = Get-TargetResource @PSBoundParameters;
        $inDesiredState = $true;

        if ($Ensure -ne $targetResource.Ensure) {
            Write-Verbose -Message ($localizedData.ResourcePropertyMismatch -f 'Ensure', $Ensure, $targetResource.Ensure);
            $inDesiredState = $false;
        }

        if ($inDesiredState) {
            Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $AuthorizerHostName);
        }
        else {
            Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $AuthorizerHostName);
        }
        return $inDesiredState;
    } #end process
} #end function Test-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String] $AuthorizerHostName,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        ImportSFModule -Name Citrix.Storefront;

        if ($Ensure -eq 'Absent') {
                
                # TO BE IMPLEMENTED
                ## Remove server from Storefront cluster
                #Write-Verbose -Message ($localizedData.RemovingFromSFCluster -f $AuthorizerHostName);
                #[ref] $null = Remove-STFStoreService -StoreService $store -Force -Confirm:$false;
        }
        elseif ($Ensure -eq 'Present') {
            Write-Verbose -Message ($localizedData.JoiningToSFCluster -f $AuthorizerHostName);
        
            $passcode = Invoke-Command -computername $AuthorizerHostName -scriptblock {
                if (Test-Path "c:\passcode.txt") {Remove-Item "c:\passcode.txt" -Force}
                [ref] $null = Schtasks /Create /F /TN StoreFrontGetPasscode /RU "SYSTEM" /TR "powershell.exe -Command '(Start-STFServerGroupJoin -IsAuthorizingServer -Confirm:`$False).Passcode | Out-File c:\passcode.txt'" /SC Once /ST 23:40
                [ref] $null = Schtasks /Run /TN StoreFrontGetPasscode /I
                
                for ($i = 120; $i -ge 0; $i--) {
                    if (Test-Path "c:\passcode.txt") {break}
                    Start-Sleep -Seconds 1
                }
                Get-Content -Path "c:\PassCode.txt"
                Remove-Item "c:\passcode.txt" -Force
                [ref] $null = Schtasks /Delete /TN StoreFrontGetPasscode /F
            }
            if ($passcode) 
            {
                Clear-STFDeployment
                Start-STFServerGroupJoin -AuthorizerHostName $AuthorizerHostName -Passcode $passcode -Confirm:$false
                Wait-STFServerGroupJoin  -Confirm:$false -WaitTimeout 5
                Invoke-Command -computername $AuthorizerHostName -scriptblock {
                    Import-Module Citrix.Storefront;
                    $result = Publish-STFServerGroupConfiguration -Confirm:$false
                    #$lastError = $result.LastError | Out-String
                    if (-not ($result.LastUpdateStatus -eq 'Complete')) {
                        Write-Verbose -Message ($localizedData.ErrorPublishingServerGroupConfiguration -f $AuthorizerHostName);
                    }
                }
            }
        }
    } #end process
} #end function Set-TargetResource
