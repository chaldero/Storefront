<# SFStoreWebReceiver\Resources.psd1 #>
ConvertFrom-StringData @'
    ResourcePropertyMismatch    = Expected web receiver property '{0}' to be '{1}', actual '{2}'.
    UpdatingResourceProperty    = Updating web receiver '{0}' property to '{1}'.
    AddingStoreFarm             = Adding Citrix Storefront web receiver '{0}'.
    UpdatingStoreFarm           = Updating Citrx Storefront web receiver '{0}'.
    RemovingStoreFarm           = Removing Citrix Storefront web receiver '{0}'.
    ResourceInDesiredState      = Citrix Storefront web receiver '{0}' is in the desired state.
    ResourceNotInDesiredState   = Citrix Storefront web receiver '{0}' is NOT in the desired state.
    CannotUpdatePropertyError   = Cannot update property '{0}'.
'@
