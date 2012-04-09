class Service < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']+"/api/v1"
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']

  schema do
    string 'type'
    string 'description'
    string 'config'
    string 'info'
  end

  def server; Server.find(server_id); end
end
