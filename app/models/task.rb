class Task < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']
  self.prefix = '/api/v1/apps/:app_name/'
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']
  self.element_name = "task"

  def app_name; prefix_options[:app_name]; end
  def app; App.find(app_name); end

  schema do
    string 'name'
    integer 'command_id'
  end

  def as_json(opts = nil)
    opts ||= {}
    opts[:except] = [opts[:except]].flatten.compact + [:updated_at, :created_at, :app_id]
    opts[:root] = self.class.name.underscore
    super(opts)
  end

  def dispatch!
    body = post(:dispatch_task, :id => self.id).body.to_s
    doc = REXML::Document.new body
    token = doc.elements.first.elements["token"].text
    return token
  end

  def drain_status(token)
    body = post(:drain_status, :id => self.id, :token => token).body.to_s
    doc = REXML::Document.new body
    return doc.elements.first.elements["message"].text, doc.elements.first.elements["logs"].text
  end
end
