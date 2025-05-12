resource "azurerm_app_service_plan" "plan" {
  name                = "${var.prefix}-appsvc-plan"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "appsvc" {
  name                = "${var.prefix}-appsvc-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}

resource "azurerm_private_endpoint" "prvendpoint" {
  name                = "${azurerm_app_service.appsvc.name}-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  
  private_service_connection {
    name                           = "${azurerm_app_service.appsvc.name}-privateconnection"
    private_connection_resource_id = azurerm_app_service.appsvc.id
    subresource_names = ["sites"]
    is_manual_connection = false
  }
}