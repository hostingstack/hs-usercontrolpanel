class PeriodicTask < Task
  self.site = HS_CONFIG['cc_api_host']
  self.prefix = '/api/v1/apps/:app_name/'
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']
  self.element_name = "task"
  # FIXME: need to support scoping
  
  schema do 
   integer 'id'
   integer 'start_hour'
   string 'interval'
   string 'name'
   integer 'enabled' 
  end
  @@_supported_intervals = nil

  def self.supported_intervals(app_name)
    @@_supported_intervals ||= self.get(:supported_intervals, :app_name => app_name)
  end
end
