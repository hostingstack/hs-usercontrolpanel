class ApplicationController < ActionController::Base
  protect_from_forgery
  
  layout :application_except_for_xhr

protected
  def application_except_for_xhr
    (request.xhr?) ? nil : 'application'
  end
  
  def login_required
    redirect_to new_user_session_path unless current_user
  end

  def load_app
    if @app = App.find(params[:app_id] || params[:id], :params => {:user_id => current_user.id})
      return true
    end
    head 401 and return false
  end
end
