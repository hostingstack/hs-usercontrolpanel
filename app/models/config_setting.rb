class ConfigSetting < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']+"/api/v1"
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']

  def self.as_hash
    r = {}
    data = find(:all)
    if data.nil?
      raise "HS CloudController API Host #{self.site} did not return config settings"
    end
    data.map{|v| r[v.name] = JSON.parse(v.data)['v']}
    return r
  end

  def self.generate_sass
    as_hash.select{|x,y| x.starts_with? 'cloud.branding.'}.map{|x,y| '$%s: %s' % [x.sub('cloud.branding.','').sub('.','_'), y]}.join(";\n")+';'
  end
end

