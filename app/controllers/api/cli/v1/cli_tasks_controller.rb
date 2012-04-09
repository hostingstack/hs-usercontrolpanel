class Api::Cli::V1::CliTasksController < Api::Cli::V1::ApiController
  before_filter :auth_required
  before_filter :app_for_user
  before_filter :find_task, :except => [:index, :create]
  respond_to :json

  def app_for_user
    @app = App.find(params[:app_id])
    raise "Permission denied" unless @app and @app.user_id == @current_user.id
  end

  def index
    tasks = @app.tasks.select do |t| t.class == CliTask end
    respond_with tasks
  end

  def create
    @command = Command.find(params[:cli_task][:command_id], {:params => {:app_name => @app.name}})
    @task = CliTask.create(
                           :command_id => @command.id,
                           :enabled => true,
                           :name => params[:cli_task][:name],
                           :app_name => @app.name,
                           )
    puts @task.inspect
    respond_with :api, :cli, :v1, @app, @task, :status => :created
  end

  def show
    respond_with :api, :cli, :v1, @app, @task
  end

  def update
    return head :forbidden if @task.class != CliTask
    if updates = params[:cli_task]
      @task.name = updates[:name] unless updates[:name].nil?
      @task.save
    end
    respond_with(:api, :cli, :v1, @app, @task)
  end

  def destroy
    return head :forbidden if @task.class != CliTask
    @task.destroy
    respond_with(:api, :cli, :v1, @app, @task)
  end

  def dispatch_task
    return head :forbidden if @task.class != CliTask
    token = @task.dispatch!
    render :json => {:token => token}.to_json(:root => :cli_task)
  end

  def drain_status
    return head :forbidden if @task.class != CliTask
    message, logs = @task.drain_status params[:token]
    render :json => {:message => message.to_s, :logs => logs}.to_json(:root => :cli_task)
  end

  private
  def find_task
    task_id = params[:id] || params[:cli_task_id]
    @task = Task.find(task_id, :params => {:app_name => params[:app_id]})
    raise "Permission denied" unless @task.app.id == @app.id
  end
end
