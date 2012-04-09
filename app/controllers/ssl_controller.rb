class SslController < ApplicationController
  before_filter :login_required
  
  def index
    @certs = KeyMaterial.find(:all, :params => {:user_id => current_user.id}).sort { |x,y| x.created_at <=> y.created_at }
  end
  
  def new
    @key_material = KeyMaterial.new :user_id => current_user.id
  end

  def create
    unless (certificate = params[:key_material][:certificate]) && (key = params[:key_material][:key])
      redirect_to new_ssl_path, :alert => "Please select both certificate and private key files"
      return
    end
    @key_material = KeyMaterial.create :user_id => current_user.id, :key => key.read, :certificate => certificate.read
    if @key_material.errors.empty?
      redirect_to ssl_index_path
    else
      render :action => :new
    end
  end

  def destroy
    @key_material = KeyMaterial.find(params[:id], :params => {:user_id => current_user.id})
    @key_material.destroy
    redirect_to ssl_index_path
  end
end
