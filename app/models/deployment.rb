class Deployment < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']
  self.prefix = '/api/v1/apps/:app_name/'
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']

  def app_name; prefix_options[:app_name]; end
  def app; App.find(app_name); end

  def deploy!
    post(:deploy, :id => self.id)
  end
  def commit_staging!
    body = post(:commit_staging, :id => self.id).body.to_s
    Rails.logger.warn("resp body: #{body.inspect}")
    doc = REXML::Document.new body
    new_deployment_id = doc.elements["deployment/new-deployment-id"].text.to_i
    Deployment.find(new_deployment_id, :params => {:app_name => app_name })
  end
  def undeploy!
    post(:undeploy, :id => self.id)
  end

  def drain_status!
    doc = REXML::Document.new post(:drain_status, :id => self.id).body.to_s
    resp = {:message => doc.elements["deployment/message"].text}
    logs = doc.elements["deployment/logs"].text
    resp[:logs] = logs if logs
    resp
  end
end
