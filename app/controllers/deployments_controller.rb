class DeploymentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_app
  before_filter :load_deployment, :except => [:new, :create, :index]

  def new
    if deployment = @app.staging_deployment || Deployment.find(:all, :params => {:app_name => @app.name, :state => :working}).first
      redirect_to [@app, deployment]
      return
    end
    @deployment_upload = Deployment.new :app_name => @app.name, :source => :upload
    @deployment_interactive = Deployment.new :app_name => @app.name, :source => :interactive
  end

  def create
    @deployment = Deployment.new :app_name => @app.name
    if params[:deployment][:source] == 'interactive'
      @deployment.source = :interactive
      @deployment.envtype = :staging
      @deployment.code_token = @app.active_deployment.code_token rescue 'empty'
    else
      @deployment.source = :upload
      unless code = params[:deployment][:code] rescue nil
        redirect_to new_app_deployment_path, :alert => "Please select a zip file to upload"
        return
      end
      archive = Codearchive.new @app, code.tempfile
      archive.save!
      code.tempfile.close!
      @deployment.code_token = archive.code_token
    end
    @deployment.save!
    @deployment.deploy!
    redirect_to [@app, @deployment]
  end

  def commit_staging
    if @deployment.envtype == 'staging'
      new_deployment = @deployment.commit_staging!
      redirect_to [@app, new_deployment]
    else
      raise "Wrong deployment type"
    end
  end

  def cancel_staging
    if @deployment.envtype == 'staging'
      @deployment.undeploy!
    else
      raise "Wrong deployment type"
    end
    redirect_to new_app_deployment_path
  end

  def show
  end

  def drain_status
    respond_to do |format|
      format.json { render :json => @deployment.drain_status! }
    end
  end

  def destroy
    @deployment.state = :removed
    @deployment.save
    redirect_to new_app_deployment_path
  end

protected
  def load_deployment
    @deployment = Deployment.find(params[:deployment_id] || params[:id], :params => {:app_name => @app.name})
  end
end
