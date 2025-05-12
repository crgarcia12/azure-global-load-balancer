$rgName = "crgar-fd-appsvc-glb-terraform-rg"
$location = "westeurope"

New-AzResourceGroup `
    -Name $rgName `
    -Location $location

$storage = New-AzStorageAccount `
    -ResourceGroupName $rgName `
    -Name "crgarfdappsvctfstor" `
    -Location $location `
    -SkuName "Standard_LRS" `
    -Kind "StorageV2" `
    -AccessTier "Hot"

# New-AzStorageContainer -
#     -Name "tfstate" `
#     -Context $storage.Context `
#     -Permission "Public"

$env:TF_VAR_SSH_USERNAME = "adminuser"
$env:TF_VAR_SSH_PASSWORD = "P@ssword123123"