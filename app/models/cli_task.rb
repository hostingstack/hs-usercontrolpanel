class CliTask < Task
  self.site = HS_CONFIG['cc_api_host']
  self.prefix = '/api/v1/apps/:app_name/'
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']
  self.element_name = "task"
  # FIXME: need to support scoping
end
