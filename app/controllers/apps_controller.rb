class AppsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_app, :except => [:index, :new, :create]
  #verify :xhr => true, :only => [:show]
  
  def index
    @apps = App.find(:all, :params => {:user_id => current_user.id}).sort { |x,y| x.created_at <=> y.created_at }
  end
  
  def show
    @domains = Domain.find(:all, :params => {:user_id => current_user.id})
  end
  
  def new
    @app = App.new
  end
  
  def destroy
    if @app.user_id == current_user.id
      @app.destroy
      head :ok
    else
      head 401
    end
  end
  
  def create
    template = AppTemplate.find(params[:template_id])
    @app = App.new :user_id => current_user.id
    @app.template_id = template.id
    @app.save
    if template.template_type == 'framework'
      @app.add_default_services(params[:database_service])
      redirect_to new_app_deployment_url(@app)
    else
      @app.add_default_services('mysql')
      @deployment = Deployment.create :app_name => @app.name, :source => :upload,
                                      :code_token => 'empty'
      @deployment.deploy!
      redirect_to [@app, @deployment]
    end
  end
  
  def databases
    @service_instances = @app.service_instances
  end

  def architecture
  end

  def ssh
  end

  def new_ssh_password
    @password = @app.new_ssh_password!
    render :text => "$('#new_password').html('Your new SSH password is: <code>#{@password}</code>');"
  end

  def maximum_web_instances
    @app.maximum_web_instances = params[:maximum_web_instances]
    @app.save
    @app = App.find(@app.name, :params => {:user_id => @app.user_id})
    render :architecture
  end
end
