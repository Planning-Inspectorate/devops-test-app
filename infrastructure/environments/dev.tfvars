apps_config = {
  app_service_plan_sku     = "P0v3"
  node_environment         = "development"
  private_endpoint_enabled = false

  logging = {
    level_file   = "silent"
    level_stdout = "info"
  }
}

alerts_enabled = false

auth_config = {
  auth_enabled           = true
  require_authentication = true
  auth_client_id         = "623081bf-a1f2-4cae-ba90-b5d264c46373"
  allowed_audiences      = "https://template-service-dev.planninginspectorate.gov.uk/.auth/login/aad/callback"
  allowed_applications   = "20838096-03c3-4e28-8053-ca7bda6b3e09"
}

common_config = {
  resource_group_name = "pins-rg-common-dev-ukw-001"
  action_group_names = {
    tech            = "pins-ag-odt-template-app-service-dev"
    service_manager = "pins-ag-odt-template-app-service-dev"
    iap             = "pins-ag-odt-template-app-service-dev"
    its             = "pins-ag-odt-template-app-service-dev"
    info_sec        = "pins-ag-odt-template-app-service-dev"
  }
}

environment = "dev"

health_check_path                 = "/health"
health_check_eviction_time_in_min = 10

sql_config = {
  admin = {
    login_username = "pins-odt-sql-dev-template"
    object_id      = "1c3b7d11-36c4-41ca-90b5-d15eafbe3b61"
  }
  sku_name    = "Basic"
  max_size_gb = 2
  retention = {
    audit_days             = 7
    short_term_days        = 7
    long_term_weekly       = "P1W"
    long_term_monthly      = "P1M"
    long_term_yearly       = "P1Y"
    long_term_week_of_year = 1
  }
  public_network_access_enabled = true
}

vnet_config = {
  address_space             = "10.18.0.0/22"
  main_subnet_address_space = "10.18.0.0/24"
  apps_subnet_address_space = "10.18.1.0/24"
}

web_app_domain = "template-service-dev.planninginspectorate.gov.uk"

frontdoor_rg = "pins-rg-shared-tooling-uks"
