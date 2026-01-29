resource "azurerm_cdn_frontdoor_origin_group" "web" {
  name = "${local.org}-fd-${local.service_name}-web-${var.environment}"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.web.id
  session_affinity_enabled = true

  health_probe {
    interval_in_seconds = 240
    path = var.health_check_path
    protocol = "Https"
    request_type = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size = 16
    successful_samples_required = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "web_app" {
  name = "${local.org}-fd-${local.service_name}-origin-${var.environment}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web.id
  enabled = true

  host_name = var.web_app_domain
  origin_host_header = var.web_app_domain
  http_port = 80
  https_port = 443
  priority = 1
  weight = 100
}

resource "azurerm_cdn_frontdoor_rule_set" "default" {
  name = "${local.org}-fd-${local.service_name}-rules-${var.environment}"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.web.id
}

resource "azurerm_cdn_frontdoor_rule" "security_headers" {
  name = "security-headers"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.default.id
  order = 1

  actions {
    response_header_action {
      header_action = "Overwrite"
      header_name = "Strict-Transport-Security"
      value = "max-age=63072000; includeSubDomains; preload"
    }
    response_header_action {
      header_action = "Overwrite"
      header_name = "X-Content-Type-Options"
      value = "nosniff"
    }
    response_header_action {
      header_action = "Overwrite"
      header_name = "X-Frame-Options"
      value = "DENY"
    }
    response_header_action {
      header_action = "Overwrite"
      header_name = "Referrer-Policy"
      value = "no-referrer"
    }
  }
}

resource "azurerm_cdn_frontdoor_route" "web" {
  name = "${local.org}-fd-${local.service_name}-route-${var.environment}"
  cdn_frontdoor_endpoint_id = data.azurerm_cdn_frontdoor_endpoint.web.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web.id

  patterns_to_match = ["/*"]
  supported_protocols = ["Https"]
  https_redirect_enabled = true
  forwarding_protocol = "MatchRequest"
  link_to_default_domain = true
  cache_enabled = false
  rule_set_ids = [azurerm_cdn_frontdoor_rule_set.default.id]
}

resource "azurerm_cdn_frontdoor_route" "assets" {
  name = "${local.org}-fd-${local.service_name}-assets-${var.environment}"
  cdn_frontdoor_endpoint_id = data.azurerm_cdn_frontdoor_endpoint.web.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web.id

  patterns_to_match = ["/assets/*"]
  supported_protocols = ["Https"]
  https_redirect_enabled = true
  forwarding_protocol = "MatchRequest"
  link_to_default_domain = true
  cache_enabled = true
  rule_set_ids = [azurerm_cdn_frontdoor_rule_set.default.id]
}

resource "azurerm_cdn_frontdoor_route" "api" {
  name = "${local.org}-fd-${local.service_name}-api-${var.environment}"
  cdn_frontdoor_endpoint_id = data.azurerm_cdn_frontdoor_endpoint.web.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web.id

  patterns_to_match = ["/api/*"]
  supported_protocols = ["Https"]
  https_redirect_enabled = true
  forwarding_protocol = "MatchRequest"
  link_to_default_domain = true
  cache_enabled = false
  rule_set_ids = [azurerm_cdn_frontdoor_rule_set.default.id]
}

resource "null_resource" "purge_all" {
  triggers = {
    endpoint_id = data.azurerm_cdn_frontdoor_endpoint.web.id
  }

  provisioner "local-exec" {
    command = "az afd endpoint purge --content-paths '/*' --profile-name ${data.azurerm_cdn_frontdoor_profile.web.name} --endpoint-name ${data.azurerm_cdn_frontdoor_endpoint.web.name} --resource-group ${data.azurerm_cdn_frontdoor_profile.web.resource_group_name}"
  }
}
