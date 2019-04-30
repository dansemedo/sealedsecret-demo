resource "azurerm_resource_group" "dxrg" {
  name     = "${var.app_rg_name}"
  location = "${var.location}"
}

#Azure AKS

resource "azurerm_kubernetes_cluster" "dxaks" {
  name                = "dxaks"
  location            = "${azurerm_resource_group.dxrg.location}"
  resource_group_name = "${azurerm_resource_group.dxrg.name}"
  dns_prefix          = "dxaks"
  
  #See this documentation to learn how to insert the write information: https://docs.microsoft.com/en-us/azure/aks/aad-integration ENABLING THE CODE BELOW WILL ENABLE AZURE AD (RBAC)
  # role_based_access_control	{

  #   azure_active_directory{

  #     client_app_id = "${var.client_app_id}"
  #     server_app_id = "${var.server_app_id}"
  #     server_app_secret = "${var.server_app_secret}"
  #     tenant_id = "${var.aad_tenant_id}"
      
  #   }

  # }

  agent_pool_profile {
    name            = "default"
    count           = 2
    vm_size         = "Standard_D2s_v3"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  tags {
    Environment = "devtest"
  }
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.dxaks.kube_config.0.client_certificate}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.dxaks.kube_config_raw}"
}

#Azure ACR

resource "azurerm_container_registry" "dxacr" {
  name                     = "dxacr"
  resource_group_name      = "${azurerm_resource_group.dxrg.name}"
  location                 = "${azurerm_resource_group.dxrg.location}"
  sku                      = "Basic"
  admin_enabled            = true
}

output "login_server_acr" {
  value = "${azurerm_container_registry.dxacr.login_server}"
}

output "admin_username" {
  value = "${azurerm_container_registry.dxacr.admin_username}"
}

output "admin_password" {
  value = "${azurerm_container_registry.dxacr.admin_password}"
}

#Azure Event Hub
resource "azurerm_eventhub_namespace" "dxeventhub" {
  name                = "dxeventhubnamespace"
  location            = "${azurerm_resource_group.dxrg.location}"
  resource_group_name = "${azurerm_resource_group.dxrg.name}"
  sku                 = "Basic"
  capacity            = 1

  tags = {
    environment = "Production"
  }
}

resource "azurerm_eventhub" "dxeventhub" {
  name                = "dxeventhub"
  namespace_name      = "${azurerm_eventhub_namespace.dxeventhub.name}"
  resource_group_name = "${azurerm_resource_group.dxrg.name}"
  partition_count     = 2
  message_retention   = 1
}

data "azurerm_eventhub_namespace" "dxeventhub" {
  name                = "${azurerm_eventhub_namespace.dxeventhub.name}"
  resource_group_name = "${azurerm_resource_group.dxrg.name}"
}

output "eventhub_namespace_id" {
  value = "${data.azurerm_eventhub_namespace.dxeventhub.id}"
}

output "eventhub_namespace_default_connection_string" {
  value = "${data.azurerm_eventhub_namespace.dxeventhub.default_primary_connection_string}"
}

output "eventhub_namespace_default_primary_key" {
  value = "${data.azurerm_eventhub_namespace.dxeventhub.default_primary_key}"
}