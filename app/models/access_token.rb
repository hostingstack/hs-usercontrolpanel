require 'expirable_token'

class AccessToken < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']+"/api/v1"
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']
  
  include ExpirableToken
  self.default_lifetime = 15.minutes

  schema do
    integer 'id'
    integer 'refresh_token_id'
    string 'token'
    integer 'client_id'
    integer 'user_id'
  end

  def user
    User.to_adapter.get(user_id)
  end
  def client
    Client.to_adapter.get(client_id)
  end
  
  def refresh_token
    RefreshToken.to_adapter.get(refresh_token_id)
  end

  def token_response
    response = {
      :access_token => token,
      :token_type => 'bearer',
      :expires_in => expires_in
    }
    response[:refresh_token] = refresh_token.token if refresh_token
    response
  end

  private

  def restrict_expires_at
    self.expires_at = [self.expires_at, refresh_token.expires_at].min
  end
end
