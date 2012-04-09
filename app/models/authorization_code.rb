require 'expirable_token'

class AuthenticationCode < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']+"/api/v1"
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']
  
  include ExpirableToken
  def access_token
    @access_token ||= expired! && user.access_tokens.create(:client => client)
  end
  def valid_request?(req)
    self.redirect_uri == req.redirect_uri
  end
end
