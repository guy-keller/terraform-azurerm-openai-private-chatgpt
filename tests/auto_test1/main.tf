terraform {
  #backend "azurerm" {}
  backend "local" { path = "terraform-test1.tfstate" }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

#################################################
# PRE-REQS                                      #
#################################################
### Random integer to generate unique names
resource "random_integer" "number" {
  min = 0001
  max = 9999
}

### Resource group to deploy the container apps private ChatGPT instance and supporting resources into
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

##################################################
# MODULE TO TEST                                 #
##################################################
module "private-chatgpt-openai" {
  source = "../.."

  #common
  solution_resource_group_name = azurerm_resource_group.rg.name
  location                     = var.location
  tags                         = var.tags

  #keyvault (OpenAI Service Account details)
  kv_config                                    = var.kv_config
  keyvault_resource_group_name                 = azurerm_resource_group.rg.name
  keyvault_firewall_default_action             = var.keyvault_firewall_default_action
  keyvault_firewall_bypass                     = var.keyvault_firewall_bypass
  keyvault_firewall_allowed_ips                = var.keyvault_firewall_allowed_ips
  keyvault_firewall_virtual_network_subnet_ids = var.keyvault_firewall_virtual_network_subnet_ids

  #Create OpenAI Service?
  create_openai_service                     = var.create_openai_service
  openai_resource_group_name                = azurerm_resource_group.rg.name
  openai_account_name                       = var.openai_account_name
  openai_custom_subdomain_name              = var.openai_custom_subdomain_name
  openai_sku_name                           = var.openai_sku_name
  openai_local_auth_enabled                 = var.openai_local_auth_enabled
  openai_outbound_network_access_restricted = var.openai_outbound_network_access_restricted
  openai_public_network_access_enabled      = var.openai_public_network_access_enabled
  openai_identity                           = var.openai_identity

  #Create Model Deployment?
  create_model_deployment = var.create_model_deployment
  model_deployment        = var.model_deployment

  #Create a solution log analytics workspace to store logs from our container apps instance
  laws_name              = var.laws_name
  laws_sku               = var.laws_sku
  laws_retention_in_days = var.laws_retention_in_days

  #Create Container App Enviornment
  cae_name = var.cae_name

  #Create a container app instance
  ca_name             = var.ca_name
  ca_revision_mode    = var.ca_revision_mode
  ca_identity         = var.ca_identity
  ca_container_config = var.ca_container_config

  #Create a container app secrets
  ca_secrets = local.ca_secrets
}