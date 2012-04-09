class Command < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']
  self.prefix = '/api/v1/apps/:app_name/'
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']

  schema do
    string 'name'
    string 'command'
  end

  def app_name; prefix_options[:app_name]; end
  def app; App.find(app_name); end

  def as_json(opts = nil)
    opts ||= {}
    opts[:except] = [opts[:except]].flatten.compact + [:updated_at, :created_at, :app_id]
    super(opts)
  end

  protected
  def validate
    errors.add("command", "must be String") unless command.kind_of?(String)
    errors.add("name", "must be String") unless name.kind_of?(String)
  end
end
