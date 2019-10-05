<# SFStore\Resources.psd1 #>
ConvertFrom-StringData @'
    ResourcePropertyMismatch    = Expected store property '{0}' to be '{1}', actual '{2}'.
    JoiningToSFCluster          = Joining Citrix Storefront server '{0}'.
    ErrorPublishingServerGroupConfiguration = An error occured while publishing ServerGroup confifguration on '{0}'.    
    ResourceInDesiredState      = Citrix Storefront cluster on '{0}' is in the desired state.
    ResourceNotInDesiredState   = Citrix Storefront store '{0}' is NOT in the desired state.
    CannotUpdatePropertyError   = Cannot update property '{0}'.
'@
