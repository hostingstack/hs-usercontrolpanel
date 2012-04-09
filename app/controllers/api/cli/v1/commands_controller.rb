class Api::Cli::V1::CommandsController < Api::Cli::V1::ApiController
  before_filter :auth_required
  before_filter :app_for_user
  before_filter :find_command, :except => [:index, :create]
  respond_to :json

  def app_for_user
    @app = App.find(params[:app_id])
    raise "Permission denied" unless @app and @app.user_id == @current_user.id
  end

  def index
    respond_with @app.commands
  end

  def create
    @command = Command.create(
                              :app_name => @app.name,
                              :source => :cli,
                              :name => params[:command][:name],
                              :command => params[:command][:command],
                              )
    respond_with :api, :cli, :v1, @app, @command, :status => :created
  end

  def show
    respond_with :api, :cli, :v1, @app, @command
  end

  def update
    return head :forbidden if @command.source.to_s != "cli"
    if updates = params[:command]
      @command.name = updates[:name] unless updates[:name].nil?
      @command.command = updates[:command] unless updates[:command].nil?
      @command.save
    end
    respond_with(:api, :cli, :v1, @app, @command)
  end

  def destroy
    return head :forbidden if @command.source.to_s != "cli"
    @command.destroy
    respond_with(:api, :cli, :v1, @app, @command)
  end

  private
  def find_command
    @command = Command.find(params[:id], :params => {:app_name => params[:app_id]})
    raise "Permission denied" unless @command.app.id == @app.id
  end

end
