class PeriodicTasksController < ApplicationController
  before_filter :login_required
  before_filter :load_app


  def index
    @periodic_tasks = PeriodicTask.to_adapter.find_all(:app_name => @app.name)
  end
  def update
    @periodic_task = PeriodicTask.to_adapter.find_all(:id => params[:id], :app_name => @app.name)[0]
    @periodic_task.enabled = params[:periodic_task][:enabled]
    @periodic_task.save!
    render :partial => 'show', :locals => {:t => @periodic_task}
  end
  def create
    @periodic_task = PeriodicTask.to_adapter.create! params[:periodic_task].merge(:app_name => @app.name)
    render :partial => 'show', :locals => {:t => @periodic_task}
  end

  def destroy
    @periodic_task = PeriodicTask.to_adapter.find_first(:app_name => @app.name, :id => params[:id])
    render :json => @periodic_task.destroy
  end
end
