class UsersController < ApplicationController
  include Devise::Controllers::InternalHelpers
  before_filter :authenticate_user!
  
  def edit_password
    self.resource = resource_class.new
    render_with_scope :editpw
  end

  def update_password
    self.resource = current_user
    ok = true
    if self.resource.valid_password? params[resource_name][:old_password]
      if params[resource_name][:password] != params[resource_name][:password_confirmation]
	self.resource.errors[:password_confirmation] = 'Your new passwords did not match. Please try again.'
	ok = false
      else
	self.resource.password=params[resource_name][:password]
	self.resource.save!
	if self.resource.errors.empty?
	  self.resource.attributes = resource_class.get(self.resource.id)
	  if self.resource.valid_password? params[resource_name][:password]
	    sign_in(resource_name, self.resource, :bypass=>true)
	    render :text => 'Your password has been changed.'
	    return
	  else
	    self.resource.errors[:password] = 'Your new password is not valid. Please choose another password.'
	    ok = false
	  end
	else
	  ok = false
	end
      end
    else
      self.resource.errors[:old_password] = 'Your old password was wrong or invalid.'
      ok = false
    end
    if not ok
      respond_with_navigational(self.resource){ render_with_scope :editpw }
    end
  end

  #def render(*args)
  #  options = args.extract_options!
  #  options[:template] = "devise/#{options[:template]}"
  #  super(*(args << options))
  #end
end
