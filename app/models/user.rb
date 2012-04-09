class User < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']+"/api/v1"
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']

  schema do
    integer 'userid'
    string 'email'
    string 'password'
  end
  
  def self.before_validation(*args)
  end
   
  devise :database_authenticatable
  devise :recoverable
  devise :oauth2_providable, 
    :oauth2_password_grantable,
    :oauth2_refresh_token_grantable,
    :oauth2_authorization_code_grantable

  def authenticatable_salt
    self.encrypted_password[0,29] if self.encrypted_password
  end
  
  def self.login(email, password)
    User.new get(:login, :email => email, :password => password)
  end
end
