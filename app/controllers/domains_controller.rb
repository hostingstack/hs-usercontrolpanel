class DomainsController < ApplicationController
  before_filter :login_required

  def index
    @domains = Domain.find(:all, :params => {:user_id => current_user.id}).select{|x| x.verified}
    @apps = App.find(:all, :params => {:user_id => current_user.id})
    @routes = @apps.map {|app| Route.find :all, :params => {:app_name => app.name}}.flatten
  end

  def list
    render :json => Domain.find(:all, :params => {:user_id => current_user.id}).select{|x| x.verified}
  end

  def new
    @domain = Domain.new
  end

  def create
    @domain = Domain.new :name => params[:domain][:name], :user_id => current_user.id
    s = ''
    begin
      @domain.save!
      redirect_to domains_path
    rescue ActiveResource::ResourceInvalid => e
      flash[:alert] = @domain.errors.full_messages[0]
      render 'new'
    end
  end
 
  def destroy
    @domain = Domain.find params[:domain_id], :params => {:user_id => current_user.id}
    @domain.destroy
    render :text => "Controlpanel.domain_deleted(#{params[:domain_id]});"
  end
end
