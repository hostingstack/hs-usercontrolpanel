require 'uri'

class App < ActiveResource::Base
  extend ActiveSupport::Memoizable
  self.site = HS_CONFIG['cc_api_host']+"/api/v1"
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']
  self.primary_key = 'name'

  schema do
    string 'template_id'
  end

  def service_instances; ServiceInstance.find(:all, :params => {:app_name => name, :user_id => user_id}) || []; end
  def deployments; Deployment.find(:all, :params => {:app_name => name}) || []; end
  def active_deployment; Deployment.find(:all, :params => {:app_name => name, :state => :success, :envtype => :production}).last || nil; end
  memoize :active_deployment
  def staging_deployment; Deployment.find(:all, :params => {:app_name => name, :state => :success, :envtype => :staging}).last || nil; end
  def pending_deployment; Deployment.find(:all, :params => {:app_name => name, :state => :working}).last || nil; end
  def commands; Command.find(:all, :params => {:app_name => name}) || []; end
  def tasks; Task.find(:all, :params => {:app_name => name}) || []; end

  def as_json(opts = nil)
    opts ||= {}
    opts[:methods] = [opts[:methods]].flatten.compact + [:display_name]
    opts[:except] = [opts[:except]].flatten.compact + [:code_archive_url_prefix, :encrypted_ssh_password, :updated_at,
                                                       :userdata, :template_id, :user_id]
    super(opts)
  end

  def screenshot_url
    a_d = active_deployment
    if a_d and CLOUD_CONFIG['services.screenshot']
      url = "%s?url=%s&timestamp=%d" % [CLOUD_CONFIG['services.screenshot'], URI.escape(default_route), a_d.finished_at.to_i]
    else
      url = "/images/app-installs/new.png"
    end
    url
  end

  def default_route
    if route = routes[0]
      'http://' + route.url
    else
      builtin_route
    end
  end

  def display_name
    if route = routes[0]
      route.url
    else
      name
    end
  end

  def new_ssh_password!
    doc = REXML::Document.new post(:new_ssh_password, :id => self.name).body.to_s
    doc.elements["password/password"].text
  end

  def add_default_services(database_service_name)
    services = []
    if database_service_name == 'pg'
      services << ServiceInstance.create(:user_id => user_id, :service_id => Service.find(:first, :params => {:type => 'Postgresql'}).id)
    elsif database_service_name == 'mysql'
      services << ServiceInstance.create(:user_id => user_id, :service_id => Service.find(:first, :params => {:type => 'Mysql'}).id)
    end
    services << ServiceInstance.create(:user_id => user_id, :service_id => Service.find(:first, :params => {:type => 'Memcached'}).id)

    services.each do |s|
      post(:add_service_instance, :service_instance_id => s.id)
    end
  end
end
