resource "azurerm_cdn_frontdoor_origin_group" "web" {
  name                     = "${local.org}-fd-${local.service_name}-web-${var.environment}"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.web.id
  provider                 = azurerm.front_door
  session_affinity_enabled = true

  health_probe {
    interval_in_seconds = 240
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "web" {
  name                           = "${local.org}-fd-${local.service_name}-web-${var.environment}"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.web.id
  enabled                        = true
  certificate_name_check_enabled = true

  host_name          = module.template_app_web.default_site_hostname
  origin_host_header = module.template_app_web.default_site_hostname
  http_port          = 80
  https_port         = 443
  priority           = 1
  weight             = 1000

  provider = azurerm.front_door
}

resource "azurerm_cdn_frontdoor_route" "web" {
  name                          = "${local.org}-fd-${local.service_name}-web-${var.environment}"
  cdn_frontdoor_endpoint_id     = data.azurerm_cdn_frontdoor_endpoint.web.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.web.id]
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  https_redirect_enabled        = true
  forwarding_protocol           = "MatchRequest"
  link_to_default_domain        = true

  provider = azurerm.front_door

}


resource "azurerm_cdn_frontdoor_custom_domain" "web" {
  name                     = "${local.org}-fd-${local.service_name}-web-${var.environment}"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.web.id
  host_name                = var.web_app_domain

  tls {
    certificate_type = "ManagedCertificate"
  }
  provider = azurerm.front_door
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "web" {
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.web.id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.web.id]
  provider                       = azurerm.front_door
}

resource "azurerm_cdn_frontdoor_firewall_policy" "web" {
  name                              = "${local.org}-fd-${local.service_name}-waf-${var.environment}"
  resource_group_name               = var.tooling_config.frontdoor_rg
  sku_name                          = data.azurerm_cdn_frontdoor_profile.web.id
  enabled                           = true
  mode                              = "Prevention"
  redirect_url                      = "https://www.contoso.com"
  custom_block_response_status_code = 403
  custom_block_response_body        = "PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkhlbGxvPC90aXRsZT48L2hlYWRlcj4KPGJvZHk+CkhlbGxvIHdvcmxkCjwvYm9keT4KPC9odG1sPg=="

  provider = azurerm.front_door
}

resource "azurerm_cdn_frontdoor_security_policy" "web" {
  name                     = "${local.org}-fd-${local.service_name}-security-policy-${var.environment}"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.web.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.web.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.web.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }

  provider = azurerm.front_door
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "web" {
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.web.id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.web.id]

  provider = azurerm.front_door
}

