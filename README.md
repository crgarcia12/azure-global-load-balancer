# Global load balancer architecture design in Azure

There are two proposals:

# Proposal 1: BGP based solution
[![Terraform](https://github.com/crgarcia12/azure-global-load-balancer/actions/workflows/infra-anycast.yml/badge.svg)](https://github.com/crgarcia12/azure-global-load-balancer/actions/workflows/infra-anycast.yml)

![architecture diagram](readme-media/architecture-bgp.png)


# Proposal 2: Front Door based solution
![architecture diagram](readme-media/architecture-frontdoor.png)


# Proposal 1: BGP - under development

## Run terraform
```
$resourceGroup = "crgar-fd-glb-terraform-rg"
$storageName = "crgarfdglbterraformstor"
az group create --name $resourceGroup --location eastus
az storage account create --resource-group $resourceGroup --name $storageName --sku Standard_LRS --encryption-services blob
az storage container create --name tfstate --account-name $storageName

$account_key=$(az storage account keys list --resource-group $resourceGroup --account-name $storageName --query '[0].value' -o tsv)
$env:ARM_ACCESS_KEY=$account_key

az upgrade
az extension add --name aks-preview
az extension update --name aks-preview

az login
az account set --subscription "..." 

az feature register --name CiliumDataplanePreview --namespace Microsoft.ContainerService
az feature show --name CiliumDataplanePreview --namespace  Microsoft.ContainerService --output table

az feature register --name AzureOverlayPreview --namespace Microsoft.ContainerService
az feature show --name AzureOverlayPreview --namespace  Microsoft.ContainerService --output table

az provider register -n Microsoft.ContainerService

terraform init
terraform apply -auto-approve
```

## Setup GitHub actions
```
# You need to be owner to do role assignments for the AKS MSI to the VNet 
az ad sp create-for-rbac --name "crgar-glb-githubaction" --role owner --scopes /subscriptions/{subscriptionid} --sdk-auth

# Create the following GH secrets
AZURE_CLIENT_ID = clientId
AZURE_CLIENT_SECRET = clientSecret
AZURE_TENANT_ID = tenantId
MVP_SUBSCRIPTION = subscriptionId

```

## VM script
``` bash
14:25

# Install frr
sudo dnf install frr
vi /etc/frr/daemons
bgpd=yes (bgp daemon)
systemctl enable frr --now

# Enter Frr config console
sudo vtysh

## See running config
show
router bgp 65111 <- autonomous system number
...
ebgp-multihop-2
65515
....
network 6.6.6.6/32


# fix destination
sudo iptables -t nat -L -> -t = which table  -L= List
DNAT all -- anywhere 6.6.6.6 to:10.220.4.5 <- when you see 6.6.6.6 replace the to to the AKS LB

# take a look at what is going on
sudo tcpdump -i eth0 tcp port 8080 -nnn

# now we need to replace the 

```

## Build the demo app
```
cd app\src\demo-app

docker login -u crgarcia

docker build -t crgarcia/demoapp:0.5.0 -f .\demo-app\Dockerfile .
docker push crgarcia/demoapp:0.5.0

$clusters = @(
	@("crgar-glb-eus-rg","crgar-glb-eus-aks"),
	@("crgar-glb-weu-rg","crgar-glb-weu-aks"),
	@("crgar-glb-weu-s1-rg","crgar-glb-weu-s1-aks"),
	@("crgar-glb-weu-s2-rg","crgar-glb-weu-s2-aks")
)

$clusters | % {
	az aks get-credentials -g $_[0] -n $_[1]
	kubectl apply -f ..\..\deployment\deployment.yaml
}

curl <demoapp k8s-service ip>:8080/api/envs
```

## Approve the VM plan from the marketplace
```
az vm image accept-terms --urn eurolinuxspzoo1620639373013:centos-8-5-free:centos-8-5-free:latest
```