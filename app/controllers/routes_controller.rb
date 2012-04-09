class RoutesController < ApplicationController
  #before_filter :login_required
  before_filter :load_app
  
  def create
    params[:route].delete(:redirect_target_id) if params[:route][:type] == 'show'
    @domain = Domain.find(:all, :params => {:user_id => current_user.id}).select{|x| x.name==params[:domain]}[0]
    if not @domain
      @domain = Domain.create(:user_id => current_user.id, :name => params[:domain])
    end
    if @domain and @domain.id
      @route = Route.create(params[:route].merge(:app_name => @app.name, :domain_id => @domain.id))
    end
    render :partial => 'list-item', :locals => {:route => @route||nil, :domain => @domain, :created => true}
  end
  
  def destroy
    @route = Route.find(params[:id], :params => {:app_name => @app.name})
    @route.destroy
    render :text => ''
  end

  def verify_dns
    @route = Route.find(params[:route_id], :params => {:app_name => @app.name})
    if request.get?
      render :partial => 'verify'
    else
      @route.verify_dns!
      @route_result = @route
      render :partial => 'verify'
    end
  end

  def verify_domain_dns
    @route = Route.find(params[:route_id], :params => {:app_name => @app.name})
    if request.get?
      render :partial => 'verify'
    else
      @route.domain.verify_dns!
      @route = Route.find(params[:route_id], :params => {:app_name => @app.name})
      @domain_result = @route.domain
      render :partial => 'verify'
    end
  end

  def refresh
    @app = App.to_adapter.find_first :name => params[:app_id]
    @route = Route.to_adapter.find_first :id => params[:route_id], :app_name => params[:app_id]
    @is_refresh = true
    render :partial => 'list-item', :locals => {:route => @route, :domain => @route.domain}
  end
end
