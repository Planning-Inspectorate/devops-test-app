apps_config = {
  app_service_plan_sku     = "P0v3"
  node_environment         = "production"
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
  allowed_audiences      = "https://template-service-test.planninginspectorate.gov.uk/.auth/login/aad/callback"
  allowed_applications   = "884ddb08-8b91-486d-aec0-9ce26ed2ffd4"
}

common_config = {
  resource_group_name = "pins-rg-common-test-ukw-001"
  action_group_names = {
    tech            = "pins-ag-odt-template-app-service-test"
    service_manager = "pins-ag-odt-template-app-service-test"
    iap             = "pins-ag-odt-iap-test"
    its             = "pins-ag-odt-its-test"
    info_sec        = "pins-ag-odt-info-sec-test"
  }
}

environment = "test"

health_check_path                 = "/health"
health_check_eviction_time_in_min = 10

sql_config = {
  admin = {
    login_username = "pins-odt-sql-test-template"
    object_id      = "6be66dee-ad48-4485-ba7b-db71d8035745"
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
  address_space             = "10.18.8.0/24"
  main_subnet_address_space = "10.18.8.0/25"
  apps_subnet_address_space = "10.18.8.128/25"
}

web_app_domain = "template-service-test.planninginspectorate.gov.uk"
