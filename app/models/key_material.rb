class KeyMaterial < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']+"/api/v1/users/:user_id/"
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']

  schema do
    integer 'id'
    integer 'user_id'
    string 'certificate'
    string 'key'
    string 'common_name'
    string 'alt_names'
    string 'expiration'
    string 'issuer'
  end
end
