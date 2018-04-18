Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',

        ## Citrix Storefront Authentication Service IIS Virtual Path
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Authentication service domain names
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $Domain,

        ## Default domain name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DefaultDomain,

        ## Hide domain field
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.Boolean] $HideDomainField,

        ## Allow user password change
        [Parameter()] [ValidateSet('Always','Never','ExpiredOnly')]
        [System.String] $AllowUserPasswordChange,      

        ## Show password expiry warning
        [Parameter()] [ValidateSet('Windows','Never','Custom')]
        [System.String] $ShowPasswordExpiryWarning,   
        
        ## Password Expiry Warning Period
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.UInt32] $PasswordExpiryWarningPeriod           
        
    )
    process {
        #ImportSFModule -Name Citrix.Storefront.Authentication*;
        [ref] $null = Get-Module Citrix.Storefront* -ListAvailable | Import-Module -Verbose:$false;
        $authenticationService = GetAuthenticationService @PSBoundParameters;
        
        $webConfig = $authenticationService.ConfigurationFile;
        $doc = (Get-Content $webConfig) -as [Xml];
        $availableDomains = $doc.configuration.'citrix.deliveryservices'.explicitBL.domainSelection.add | Select-Object domain -ExpandProperty domain;      
        $explicitCommonOptions = Get-STFExplicitCommonOptions -AuthenticationService $authenticationService;
        
        $targetResource = @{
            HideDomainField = $explicitCommonOptions.HideDomainField;
            AllowUserPasswordChange = $explicitCommonOptions.AllowUserPasswordChange;
            ShowPasswordExpiryWarning = $explicitCommonOptions.ShowPasswordExpiryWarning;
            PasswordExpiryWarningPeriod = $explicitCommonOptions.PasswordExpiryWarningPeriod;
            DefaultDomain = $explicitCommonOptions.DomainSelection;
            Domain = $availableDomains;
            Ensure = if ($explicitCommonOptions) { 'Present' } else { 'Absent' };
        }
        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',

        ## Citrix Storefront Authentication Service IIS Virtual Path
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Authentication service domain names
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $Domain,

        ## Default domain name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DefaultDomain,

        ## Hide domain field
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.Boolean] $HideDomainField,

        ## Allow user password change
        [Parameter()] [ValidateSet('Always','Never','ExpiredOnly')]
        [System.String] $AllowUserPasswordChange,      

        ## Show password expiry warning
        [Parameter()] [ValidateSet('Windows','Never','Custom')]
        [System.String] $ShowPasswordExpiryWarning,   
        
        ## Password Expiry Warning Period
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.UInt32] $PasswordExpiryWarningPeriod    
    )
    process {
        $targetResource = Get-TargetResource @PSBoundParameters;
        $inDesiredState = $true;

        if ($Ensure -ne $targetResource.Ensure) {
            Write-Verbose -Message ($localizedData.ResourcePropertyMismatch -f 'Ensure', $Ensure, $targetResource.Ensure);
            $inDesiredState = $false;
        }

        ## Only check all remaing properties if we're setting
        if ($Ensure -eq 'Present') {
            $properties = @('Domain','DefaultDomain','HideDomainField','AllowUserPasswordChange','ShowPasswordExpiryWarning','PasswordExpiryWarningPeriod');
            foreach ($property in $properties) {
                if ($PSBoundParameters.ContainsKey($property)) {
                    $propertyValue = (Get-Variable -Name $property).Value;
                    if ($targetResource.$property -ne $propertyValue) {
                        $message = $localizedData.ResourcePropertyMismatch -f $property, $propertyValue, $targetResource.$property;
                        Write-Verbose -Message $message;
                        $inDesiredState = $false;
                    }
                } #end if PSBoundParameter
            } #end foreach property
        } #end if ensure is present

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
        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',

         ## Citrix Storefront Authentication Service IIS Virtual Path
         [Parameter(Mandatory)]
         [System.String] $VirtualPath,
 
         ## Authentication service domain names
         [Parameter()] [ValidateNotNullOrEmpty()]
         [System.String[]] $Domain,
 
         ## Default domain name
         [Parameter()] [ValidateNotNullOrEmpty()]
         [System.String] $DefaultDomain,
 
         ## Hide domain field
         [Parameter()] [ValidateNotNullOrEmpty()]
         [System.Boolean] $HideDomainField,
 
         ## Allow user password change
         [Parameter()] [ValidateSet('Always','Never','ExpiredOnly')]
         [System.String] $AllowUserPasswordChange,      
 
         ## Show password expiry warning
         [Parameter()] [ValidateSet('Windows','Never','Custom')]
         [System.String] $ShowPasswordExpiryWarning,   
         
         ## Password Expiry Warning Period
         [Parameter()] [ValidateNotNullOrEmpty()]
         [System.UInt32] $PasswordExpiryWarningPeriod
    )
    process {
        #ImportSFModule -Name Citrix.Storefront.Authentication*;
        Get-Module Citrix.Storefront* -ListAvailable -Verbose:$false | Import-Module -Verbose:$false;
        $authenticationService = GetAuthenticationService @PSBoundParameters;

        Write-Verbose -Message ($localizedData.ConfiguringExplicitCommonOptions -f $VirtualPath);
        $addParams = @{
            AuthenticationService = $authenticationService;
        }
        if ($PSBoundParameters.ContainsKey('Domain')) {
            $addParams['Domains'] = $Domain;
        }
        if ($PSBoundParameters.ContainsKey('DefaultDomain')) {
            $addParams['DefaultDomain'] = $DefaultDomain;
        }
        if ($PSBoundParameters.ContainsKey('HideDomainField')) {
            $addParams['HideDomainField'] = $HideDomainField;
        }
        if ($PSBoundParameters.ContainsKey('AllowUserPasswordChange')) {
            $addParams['AllowUserPasswordChange'] = $AllowUserPasswordChange;
        }
        if ($PSBoundParameters.ContainsKey('ShowPasswordExpiryWarning')) {
            $addParams['ShowPasswordExpiryWarning'] = $ShowPasswordExpiryWarning;
        }
        if ($PSBoundParameters.ContainsKey('PasswordExpiryWarningPeriod')) {
            $addParams['PasswordExpiryWarningPeriod'] = $PasswordExpiryWarningPeriod;
        }

        [ref] $null = Set-STFExplicitCommonOptions @addParams;
    } #end process
} #end function Set-TargetResource
