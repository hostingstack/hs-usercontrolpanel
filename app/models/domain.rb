require 'net/dns/resolver'

class Domain < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']+"/api/v1"
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']

  schema do
    string 'name'
  end

  def verify_dns!
    self.attributes = JSON.parse(post(:verify).body)
  end
end
