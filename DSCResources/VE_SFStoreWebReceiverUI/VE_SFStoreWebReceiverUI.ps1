Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Receiver for Web virtual path, e.g. /Citrix/StoreWeb
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        [Parameter()]
        [System.Boolean] $AutoLaunchDesktop,

        [Parameter()]
        [System.UInt64] $MultiClickTimeout,

        [Parameter()]
        [System.Boolean] $EnableAppsFolderView,

        [Parameter()]
        [System.Boolean] $WorkspaceControlEnabled,

        [Parameter()]
        [System.Boolean] $AutoReconnectAtLogon,

        [Parameter()] [ValidateSet('Disconnect','None','Terminate')]
        [System.String] $LogoffAction,

        [Parameter()]
        [System.Boolean] $ShowReconnectButton,

        [Parameter()]
        [System.Boolean] $ShowDisconnectButton,

        [Parameter()]
        [System.Boolean] $ReceiverConfigurationEnabled,

        [Parameter()]
        [System.Boolean] $AppShortcutsEnabled,

        [Parameter()]
        [System.Boolean] $AppShortcutsAllowSessionReconnect,

        [Parameter()]
        [System.Boolean] $ShowAppsView,

        [Parameter()]
        [System.Boolean] $ShowDesktopsView,

        [Parameter()] [ValidateSet('Apps','Auto','Desktops')]
        [System.String] $Defaultview

    )
    process {
        ImportSFModule -Name 'Citrix.StoreFront.WebReceiver';
        $webReceiverService = GetWebReceiverService -VirtualPath $VirtualPath;
        
        if ($null -eq $webReceiverService)
        {
            $webReceiverUI = ''
        }
        else
        {
            $webReceiverUI = Get-STFWebReceiverUserInterface -WebReceiverService $webReceiverService    
        }       

        $targetResource = @{
            AutoLaunchDesktop = $webReceiverUI.AutoLaunchDesktop
            MultiClickTimeout = $webReceiverUI.MultiClickTimeout;
            EnableAppsFolderView = $webReceiverUI.EnableAppsFolderView;
            WorkspaceControlEnabled = $webReceiverUI.WorkspaceControl.Enabled;            
            AutoReconnectAtLogon = $webReceiverUI.WorkspaceControl.AutoReconnectAtLogon;
            LogoffAction = $webReceiverUI.WorkspaceControl.LogoffAction;
            ShowReconnectButton = $webReceiverUI.WorkspaceControl.ShowReconnectButton;
            ShowDisconnectButton = $webReceiverUI.WorkspaceControl.ShowDisconnectButton;
            ReceiverConfigurationEnabled = $webReceiverUI.ReceiverConfiguration.Enabled;
            AppShortcutsEnabled = $webReceiverUI.AppShortcuts.Enabled;
            AppShortcutsAllowSessionReconnect = $webReceiverUI.AppShortcuts.AllowSessionReconnect;
            ShowAppsView = $webReceiverUI.UIViews.ShowAppsView;
            ShowDesktopsView = $webReceiverUI.UIViews.ShowDesktopsView;
            Defaultview = $webReceiverUI.UIViews.ShowDesktopsView;

        }  

        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Receiver for Web virtual path, e.g. /Citrix/StoreWeb
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        [Parameter()]
        [System.Boolean] $AutoLaunchDesktop,

        [Parameter()]
        [System.UInt64] $MultiClickTimeout,

        [Parameter()]
        [System.Boolean] $EnableAppsFolderView,

        [Parameter()]
        [System.Boolean] $WorkspaceControlEnabled,

        [Parameter()]
        [System.Boolean] $AutoReconnectAtLogon,

        [Parameter()] [ValidateSet('Disconnect','None','Terminate')]
        [System.String] $LogoffAction,

        [Parameter()]
        [System.Boolean] $ShowReconnectButton,

        [Parameter()]
        [System.Boolean] $ShowDisconnectButton,

        [Parameter()]
        [System.Boolean] $ReceiverConfigurationEnabled,

        [Parameter()]
        [System.Boolean] $AppShortcutsEnabled,

        [Parameter()]
        [System.Boolean] $AppShortcutsAllowSessionReconnect,

        [Parameter()]
        [System.Boolean] $ShowAppsView,

        [Parameter()]
        [System.Boolean] $ShowDesktopsView,

        [Parameter()] [ValidateSet('Apps','Auto','Desktops')]
        [System.String] $Defaultview

    )
    process {
        $targetResource = Get-TargetResource @PSBoundParameters;
        $inDesiredState = $true;
        
        foreach ($property in $targetResource.Keys) {
            if ($PSBoundParameters.ContainsKey($property)) {
                $propertyValue = (Get-Variable -Name $property).Value;
                if ($targetResource[$property] -ne $propertyValue) {
                    $message = $localizedData.ResourcePropertyMismatch -f $property, $propertyValue, $targetResource.$property;
                    Write-Verbose -Message $message;
                    $inDesiredState = $false;
                }
            } #end if PSBoundParameter
        } #end foreach property


        if ($inDesiredState) {
            Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $VirtualPath);
        }
        else {
            Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $VirtualPath);
        }
        return $inDesiredState;

    } #end process
} #end function Test-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param (
        ## Receiver for Web virtual path, e.g. /Citrix/StoreWeb
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        [Parameter()]
        [System.Boolean] $AutoLaunchDesktop,

        [Parameter()]
        [System.UInt64] $MultiClickTimeout,

        [Parameter()]
        [System.Boolean] $EnableAppsFolderView,

        [Parameter()]
        [System.Boolean] $WorkspaceControlEnabled,

        [Parameter()]
        [System.Boolean] $AutoReconnectAtLogon,

        [Parameter()] [ValidateSet('Disconnect','None','Terminate')]
        [System.String] $LogoffAction,

        [Parameter()]
        [System.Boolean] $ShowReconnectButton,

        [Parameter()]
        [System.Boolean] $ShowDisconnectButton,

        [Parameter()]
        [System.Boolean] $ReceiverConfigurationEnabled,

        [Parameter()]
        [System.Boolean] $AppShortcutsEnabled,

        [Parameter()]
        [System.Boolean] $AppShortcutsAllowSessionReconnect,

        [Parameter()]
        [System.Boolean] $ShowAppsView,

        [Parameter()]
        [System.Boolean] $ShowDesktopsView,

        [Parameter()] [ValidateSet('Apps','Auto','Desktops')]
        [System.String] $Defaultview

    )
    process {
        ImportSFModule -Name 'Citrix.StoreFront.WebReceiver';
        $webReceiverService = GetWebReceiverService -VirtualPath $VirtualPath;
        
        if ($null -eq $webReceiverService)
        {
            $webReceiverUI = ''
        }
        else
        {
            $webReceiverUI = Get-STFWebReceiverUserInterface -WebReceiverService $webReceiverService
        }

        $targetResource = Get-TargetResource @PSBoundParameters;
        
        if ($webReceiverUI) {
            $addSTFWebReceiverUIParams = @{
                'WebReceiverService' = $webReceiverService
            }
            if ($PSBoundParameters.ContainsKey('AutoLaunchDesktop') -and $AutoLaunchDesktop -ne $targetResource.AutoLaunchDesktop) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'AutoLaunchDesktop', $AutoLaunchDesktop);
                $addSTFWebReceiverUIParams['AutoLaunchDesktop'] = $AutoLaunchDesktop
            }
            if ($PSBoundParameters.ContainsKey('MultiClickTimeout') -and $MultiClickTimeout -ne $targetResource.MultiClickTimeout) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'MultiClickTimeout', $MultiClickTimeout);
                $addSTFWebReceiverUIParams['MultiClickTimeout'] = $MultiClickTimeout
            }
            if ($PSBoundParameters.ContainsKey('EnableAppsFolderView') -and $EnableAppsFolderView -ne $targetResource.EnableAppsFolderView) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'EnableAppsFolderView', $EnableAppsFolderView);
                $addSTFWebReceiverUIParams['EnableAppsFolderView'] = $EnableAppsFolderView
            }
            if ($PSBoundParameters.ContainsKey('WorkspaceControlEnabled') -and $WorkspaceControlEnabled -ne $targetResource.WorkspaceControlEnabled) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'WorkspaceControlEnabled', $WorkspaceControlEnabled);
                $addSTFWebReceiverUIParams['WorkspaceControlEnabled'] = $WorkspaceControlEnabled
            }            
            if ($PSBoundParameters.ContainsKey('AutoReconnectAtLogon') -and $AutoReconnectAtLogon -ne $targetResource.AutoReconnectAtLogon) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'AutoReconnectAtLogon', $AutoReconnectAtLogon);
                $addSTFWebReceiverUIParams['WorkspaceControlAutoReconnectAtLogon'] = $AutoReconnectAtLogon
            }        
            if ($PSBoundParameters.ContainsKey('LogoffAction') -and $LogoffAction -ne $targetResource.LogoffAction) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'LogoffAction', $LogoffAction);
                $addSTFWebReceiverUIParams['WorkspaceControlLogoffAction'] = $LogoffAction
            }
            if ($PSBoundParameters.ContainsKey('ShowReconnectButton') -and $ShowReconnectButton -ne $targetResource.ShowReconnectButton) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'ShowReconnectButton', $ShowReconnectButton);
                $addSTFWebReceiverUIParams['WorkspaceControlShowReconnectButton'] = $ShowReconnectButton
            }  
            if ($PSBoundParameters.ContainsKey('ShowDisconnectButton') -and $ShowDisconnectButton -ne $targetResource.ShowDisconnectButton) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'ShowDisconnectButton', $ShowDisconnectButton);
                $addSTFWebReceiverUIParams['WorkspaceControlShowDisconnectButton'] = $ShowDisconnectButton
            }
            if ($PSBoundParameters.ContainsKey('ReceiverConfigurationEnabled') -and $ReceiverConfigurationEnabled -ne $targetResource.ReceiverConfigurationEnabled) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'ReceiverConfigurationEnabled', $ReceiverConfigurationEnabled);
                $addSTFWebReceiverUIParams['ReceiverConfigurationEnabled'] = $ReceiverConfigurationEnabled
            }
            if ($PSBoundParameters.ContainsKey('ReceiverConfigurationEnabled') -and $ReceiverConfigurationEnabled -ne $targetResource.AppShortcutsEnabled) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'AppShortcutsEnabled', $AppShortcutsEnabled);
                $addSTFWebReceiverUIParams['AppShortcutsEnabled'] = $AppShortcutsEnabled
            }
            if ($PSBoundParameters.ContainsKey('AppShortcutsAllowSessionReconnect') -and $AppShortcutsAllowSessionReconnect -ne $targetResource.AppShortcutsAllowSessionReconnect) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'AppShortcutsAllowSessionReconnect', $AppShortcutsAllowSessionReconnect);
                $addSTFWebReceiverUIParams['AppShortcutsAllowSessionReconnect'] = $AppShortcutsAllowSessionReconnect
            }
            if ($PSBoundParameters.ContainsKey('ShowAppsView') -and $ShowAppsView -ne $targetResource.ShowAppsView) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'ShowAppsView', $ShowAppsView);
                $addSTFWebReceiverUIParams['ShowAppsView'] = $ShowAppsView
            }
            if ($PSBoundParameters.ContainsKey('WorkspaceControlEnabled') -and $ShowDesktopsView -ne $targetResource.ShowDesktopsView) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'ShowDesktopsView', $ShowDesktopsView);
                $addSTFWebReceiverUIParams['ShowDesktopsView'] = $ShowDesktopsView
            }
            if ($PSBoundParameters.ContainsKey('Defaultview') -and $Defaultview -ne $targetResource.Defaultview) {
                Write-Verbose ($localizedData.UpdatingResourceProperty -f 'Defaultview', $Defaultview);
                $addSTFWebReceiverUIParams['Defaultview'] = $Defaultview
            }

            [ref] $null = Set-STFWebReceiverUserInterface @addSTFWebReceiverUIParams;
        }

    } #end process
} #end function Set-TargetResource
