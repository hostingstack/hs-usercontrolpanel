class Api::Cli::V1::AppsController < Api::Cli::V1::ApiController
  before_filter :auth_required
  before_filter :app_for_user, :except => [:index, :create]
  respond_to :json

  def app_for_user
    @app = App.find(params[:app_id] || params[:id])
    raise "Permission denied" unless @app and @app.user_id == @current_user.id
  end

  def index
    apps = App.find(:all, :params => {:user_id => @current_user.id}).sort { |x,y| x.created_at <=> y.created_at }
    render :json => apps.to_json
  end

  def create
    app = App.new :user_id => current_user.id
    app.template_id = params[:app][:template_id]
    app.save
    if params[:database_service] && params[:database_service] != ''
      app.add_default_services(params[:database_service])
    end
    render :json => app.to_json
  end

  def show
    j = @app.to_json
    data = JSON.parse(j)
    if @app.pending_deployment
      data[:blocking_deployment] = 'A previous deployment is still pending. You MUST wait for it before continuing.'
    elsif @app.staging_deployment
      data[:blocking_deployment] = 'An SFTP/SSH staging environment exists. You MUST remove it in the web-interface before continuing.'
    elsif @app.active_deployment and @app.active_deployment.source.to_s == :interactive.to_s
      data[:warn_deployment] = 'The current instance has been created interactively via SSH/SFTP. Deploying now will overwrite all changes made in the current instance.'
    end
    render :json => data
  end

  def upload
    archive = Codearchive.new @app, params[:code].tempfile
    archive.save!
    params[:code].tempfile.close!
    render :json => {:code_token => archive.code_token}
  end

  def deploy
    code_token = params[:code_token]
    @deployment = Deployment.create :app_name => @app.name, :code_token => params[:code_token], :source => :cli
    raise @deployment.errors.full_messages.first unless @deployment.errors.empty?
    @deployment.deploy!
    render :json => {:token => @deployment.id}
  end

  def deploy_status
    @deployment = Deployment.find(params[:deploy_token], :params => {:app_name => @app.name})
    resp = @deployment.drain_status!
    render :json => resp
  end

  def set_template
    tpl = AppTemplate.all.reject{|x| x.recipe_name != params[:template]}[0]
    raise "Template not found" if tpl.nil?
    @app.template = tpl
    @app.save
    render :json => {:message => 'OK'}
  end
end
