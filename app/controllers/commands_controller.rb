class CommandsController < ApplicationController
  before_filter :login_required
  before_filter :load_app

  def index
    @commands = Command.to_adapter.find_all :app_name => @app.name
    @periodic_tasks = PeriodicTask.to_adapter.find_all(:app_name => @app.name)

    @c = Command.new :app_name => @app.name if not @c or @c.id
    @cs = {}
    @commands.each{|c| @cs[c] = @periodic_tasks.select{|t| t.command_id == c.id}}
  end

  def create
    @c = Command.to_adapter.create! params[:command].merge({:source => :web, :app_name => @app.name})
    @periodic_task = PeriodicTask.to_adapter.create! params[:periodic_task].merge(:app_name => @app.name,:command_id => @c.id,:enabled=>true)
    index()
    render :index
  end

  def update
    @c = Command.to_adapter.find_first :app_name => @app.name, :id => params[:id]
    @c.command = params[:command]
    @c.save

    render :text => 'ok'
  end

  def destroy
    @c = Command.to_adapter.find_first :app_name => @app.name, :id => params[:id]
    @c.destroy
    render :json => 'ok'
  end
end
