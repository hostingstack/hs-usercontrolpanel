class DeploymentInstall < ActiveResource::Base
  self.site = HS_CONFIG['cc_api_host']
  self.prefix = '/api/v1/apps/:app_name/deployments/:deployment_id/'
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']

  schema do
    integer 'service_id'
  end

  def deployment_id; prefix_options[:deployment_id]; end
  def deployment; Deployment.find(deployment_id, :params => {:app_name => app_name}); end
  def app_name; prefix_options[:app_name]; end
  def app; App.find(app_name); end

  def service; Service.find(service_id) || []; end
end
