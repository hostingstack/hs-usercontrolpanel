require 'expirable_token'

class RefreshToken < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']+"/api/v1"
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']

  schema do
    integer 'id'
    integer 'client_id'
    string 'token'
    integer 'user_id'
  end

  def user
    User.to_adapter.get(user_id)
  end
  def client
    Client.to_adapter.get(client_id)
  end
  
  include ExpirableToken
  self.default_lifetime = 1.month
end
