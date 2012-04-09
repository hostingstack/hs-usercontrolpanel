SwitchUser.setup do |config|
  config.controller_guard = lambda { |current_user, request| current_user.is_admin }
  config.view_guard = lambda { |current_user, request| current_user.is_admin }
end
