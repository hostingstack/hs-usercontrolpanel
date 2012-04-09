class ServiceInstance < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']+"/api/v1/users/:user_id/"
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']

  schema do
    integer 'service_id'
    integer 'user_id'
    integer 'port'
  end
end
