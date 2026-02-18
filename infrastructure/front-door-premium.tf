resource "azurerm_cdn_frontdoor_origin_group" "web" {
  name                     = "${local.org}-fd-${local.service_name}-web-${var.environment}"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.web.id
  session_affinity_enabled = true
  provider                 = azurerm.front_door

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

import {
  id = "/subscriptions/edb1ff78-90da-4901-a497-7e79f966f8e2/resourceGroups/pins-rg-common-test-ukw-001/providers/Microsoft.Cdn/profiles/pins-fd-common-tooling/originGroups/pins-fd-template-web-test/origins/pins-fd-template-origin-test"
  to = azurerm_cdn_frontdoor_origin.web_app
}

resource "azurerm_cdn_frontdoor_origin" "web_app" {
  name                          = "${local.org}-fd-${local.service_name}-origin-${var.environment}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web.id
  enabled                       = true

  provider = azurerm.front_door

  host_name                      = module.template_app_web.default_site_hostname
  origin_host_header             = module.template_app_web.default_site_hostname
  http_port                      = 80
  https_port                     = 443
  priority                       = 1
  weight                         = 100
  certificate_name_check_enabled = true
}

  provider                      = azurerm.front_door
  patterns_to_match             = ["/*"]
  supported_protocols         git add front-door-premium.tf
= ["Http", "Https"]
  https_redirect_enabled        = true
  forwarding_protocol           = "MatchRequest"
  link_to_default_domain        = true
}

