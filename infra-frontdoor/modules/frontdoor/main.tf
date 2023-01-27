###########################################################
#                     FrontDoor
###########################################################


resource "azurerm_cdn_frontdoor_profile" "main" {
  name                     = "${var.prefix}-fd"
  resource_group_name      = var.resource_group_name
  response_timeout_seconds = 16

  sku_name = "Premium_AzureFrontDoor"
}

# Default Front Door endpoint
resource "azurerm_cdn_frontdoor_endpoint" "default" {
  name    = "${var.prefix}-primaryendpoint" # needs to be a gloablly unique name
  enabled = true

  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

resource "azurerm_cdn_frontdoor_custom_domain" "global" {
  name                     = "CustomDomainFrontendEndpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  host_name   = local.frontdoor_fqdn
  dns_zone_id = data.azurerm_dns_zone.customdomain.id

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

# resource "azurerm_cdn_frontdoor_custom_domain_association" "global" {
#   cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.global.id
#   cdn_frontdoor_route_ids = setunion(
#     [azurerm_cdn_frontdoor_route.globalstorage.id],
#     azurerm_cdn_frontdoor_route.staticstorage.*.id,
#     azurerm_cdn_frontdoor_route.backendapi.*.id
#   )
# }

# Front Door Origin Group used for Backend APIs hosted on AKS
resource "azurerm_cdn_frontdoor_origin_group" "backendapis" {
  name = "BackendApis"

  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  session_affinity_enabled = false

  health_probe {
    protocol            = "Https"
    request_type        = "HEAD"
    path                = "/api/envs"
    interval_in_seconds = 30
  }

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 1
    additional_latency_in_milliseconds = 1000
  }
}

# # Front Door Origin Group used for Global Storage Accounts
# resource "azurerm_cdn_frontdoor_origin_group" "globalstorage" {
#   name = "GlobalStorage"

#   session_affinity_enabled = false

#   health_probe {
#     protocol            = "Https"
#     request_type        = "HEAD"
#     path                = "/health.check"
#     interval_in_seconds = 30
#   }

#   load_balancing {
#     sample_size                        = 4
#     successful_samples_required        = 2
#     additional_latency_in_milliseconds = 1000
#   }

#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
# }

# # Front Door Origin Group used for Static Storage Accounts
# resource "azurerm_cdn_frontdoor_origin_group" "staticstorage" {
#   name = "StaticStorage"

#   session_affinity_enabled = false

#   health_probe {
#     protocol            = "Https"
#     request_type        = "HEAD"
#     path                = "/"
#     interval_in_seconds = 30
#   }

#   load_balancing {
#     sample_size                        = 4
#     successful_samples_required        = 2
#     additional_latency_in_milliseconds = 1000
#   }

#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
# }

# resource "azurerm_cdn_frontdoor_origin" "globalstorage-primary" {
#   name      = "primary"
#   host_name = azurerm_storage_account.global.primary_web_host

#   http_port  = 80
#   https_port = 443
#   weight     = 1
#   priority   = 1

#   enabled                        = true
#   certificate_name_check_enabled = true

#   origin_host_header = azurerm_storage_account.global.primary_web_host

#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.globalstorage.id
# }

# resource "azurerm_cdn_frontdoor_origin" "globalstorage-secondary" {
#   name      = "secondary"
#   host_name = azurerm_storage_account.global.secondary_web_host

#   http_port  = 80
#   https_port = 443
#   weight     = 1
#   priority   = 2

#   enabled                        = true
#   certificate_name_check_enabled = true

#   origin_host_header = azurerm_storage_account.global.secondary_web_host

#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.globalstorage.id
# }

# resource "azurerm_cdn_frontdoor_route" "globalstorage" {
#   name                          = "GlobalStorageRoute"
#   cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.default.id
#   enabled                       = true
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.globalstorage.id

#   cdn_frontdoor_custom_domain_ids = [
#     azurerm_cdn_frontdoor_custom_domain.global.id,
#   ]

#   patterns_to_match = [
#     "/images/*"
#   ]

#   supported_protocols = [
#     "Http", # HTTP needs to be enabled explicity, so that https_redirect_enabled = true (default) works
#     "Https"
#   ]
#   forwarding_protocol = "HttpsOnly"

#   cdn_frontdoor_origin_ids = [
#     azurerm_cdn_frontdoor_origin.globalstorage-primary.id,
#     azurerm_cdn_frontdoor_origin.globalstorage-secondary.id
#   ]
# }

# resource "azurerm_cdn_frontdoor_origin" "backendapi" {
#   for_each = { for index, backend in var.backends_BackendApis : backend.address => backend }

#   name               = replace(each.value.address, ".", "-") # Name must not contain dots, so we use hyphens instead
#   host_name          = each.value.address
#   origin_host_header = each.value.address
#   weight             = each.value.weight

#   enabled                        = each.value.enabled
#   certificate_name_check_enabled = true

#   dynamic "private_link" {
#     for_each = each.value.privatelink_service_id != "" ? [1] : [] # a workaround to make a nested block optional
#     content {
#       request_message        = "Request access for CDN Frontdoor Private Link Origin for prefix ${var.prefix}"
#       location               = each.value.privatelink_location
#       private_link_target_id = each.value.privatelink_service_id
#     }
#   }

#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.backendapis.id

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "azurerm_cdn_frontdoor_route" "backendapi" {
#   count                         = length(var.backends_BackendApis) > 0 ? 1 : 0 # only create this route if there are already backends
#   name                          = "BackendApiRoute"
#   cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.default.id
#   enabled                       = true
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.backendapis.id

#   cdn_frontdoor_custom_domain_ids = [
#     azurerm_cdn_frontdoor_custom_domain.global.id,
#   ]

#   patterns_to_match = [
#     "/catalogservice/*",
#     "/healthservice/*"
#   ]

#   supported_protocols = [
#     "Http", # HTTP needs to be enabled explicity, so that https_redirect_enabled = true (default) works
#     "Https"
#   ]
#   forwarding_protocol = "HttpsOnly"

#   cdn_frontdoor_origin_ids = [for i, b in azurerm_cdn_frontdoor_origin.backendapi : b.id]
# }

# resource "azurerm_cdn_frontdoor_origin" "staticstorage" {
#   for_each = { for index, backend in var.backends_StaticStorage : backend.address => backend }

#   name               = replace(each.value.address, ".", "-") # Name must not contain dots, so we use hyphens instead
#   host_name          = each.value.address
#   origin_host_header = each.value.address
#   weight             = each.value.weight

#   enabled                        = each.value.enabled
#   certificate_name_check_enabled = true

#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.staticstorage.id

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "azurerm_cdn_frontdoor_route" "staticstorage" {
#   count                         = length(var.backends_StaticStorage) > 0 ? 1 : 0 # only create this route if there are already backends
#   name                          = "StaticStorageRoute"
#   cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.default.id
#   enabled                       = true
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.staticstorage.id

#   cdn_frontdoor_custom_domain_ids = [
#     azurerm_cdn_frontdoor_custom_domain.global.id,
#   ]

#   patterns_to_match = [
#     "/*"
#   ]

#   supported_protocols = [
#     "Http", # HTTP needs to be enabled explicity, so that https_redirect_enabled = true (default) works
#     "Https"
#   ]
#   forwarding_protocol = "HttpsOnly"

#   cdn_frontdoor_origin_ids = [for i, b in azurerm_cdn_frontdoor_origin.staticstorage : b.id]
# }

#### WAF

resource "azurerm_cdn_frontdoor_firewall_policy" "global" {
  name                = "${replace(var.prefix, "-", "")}globalfdfp"
  resource_group_name = var.resource_group_name
  sku_name            = azurerm_cdn_frontdoor_profile.main.sku_name
  enabled             = true
  mode                = "Prevention"

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.0"
    action  = "Block"
  }
  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "global" {
  name                     = "Global-Security-Policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.global.id
      association {
        patterns_to_match = ["/*"]

        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.default.id
        }

        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.global.id
        }
      }
    }
  }
}

###########################################################
#                        DNS
###########################################################
locals {
  front_door_subdomain = "glbapp"
  frontdoor_fqdn       = "${local.front_door_subdomain}.${data.azurerm_dns_zone.customdomain.name}"
}

data "azurerm_dns_zone" "customdomain" {
  name                = "crgar.net"
  resource_group_name = "crgar-domain-shared-rg"
}

# CNAME to point to the Front Door
resource "azurerm_dns_cname_record" "afd_subdomain" {
  name                = local.front_door_subdomain
  zone_name           = data.azurerm_dns_zone.customdomain.name
  resource_group_name = data.azurerm_dns_zone.customdomain.resource_group_name
  ttl                 = 1
  record              = azurerm_cdn_frontdoor_endpoint.default.host_name
}

# TXT record for Front Door custom domain validation
resource "azurerm_dns_txt_record" "global" {
  name                = "_dnsauth.${local.front_door_subdomain}"
  zone_name           = data.azurerm_dns_zone.customdomain.name
  resource_group_name = data.azurerm_dns_zone.customdomain.resource_group_name
  ttl                 = 1
  record {
    value = azurerm_cdn_frontdoor_custom_domain.global.validation_token
  }
}
