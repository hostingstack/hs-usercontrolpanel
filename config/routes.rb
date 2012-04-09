Controlpanel::Application.routes.draw do
  devise_for :users
  devise_scope :user do
    get "/users/editpw" => "users#edit_password", :as => :editpw
    put "/users/editpw" => "users#update_password", :as => :editpwpost
    get "/users/profile" => "users#profile", :as => :userprofile
  end
  
  resources :apps do
    get 'databases'
    get 'ssh'
    get 'architecture'
    post 'new_ssh_password'
    post 'maximum_web_instances'
    resources :routes do
      get :verify_dns
      post :verify_dns
      post :verify_domain_dns
      get :refresh
    end
    resources :service_instances
    resources :deployments do
      post :commit_staging
      post :cancel_staging
      get :drain_status
    end
    resources :commands
    resources :periodic_tasks
    collection do
      resources :templates, :controller => "app_templates"
    end
  end
  
  resources :domains do
    post 'destroy'
    collection do
      post 'get_or_create'
      get 'list'
    end
    get :verify_dns
    post :verify_dns
  end

  resources :ssl

  namespace 'api' do
    namespace 'cli' do
      namespace 'v1' do
        resources :apps do
          get 'info'
          post 'upload'
          post 'deploy'
          get 'deploy_status'
          post 'set_template'
          resources :commands
          resources :cli_tasks do
            post 'dispatch_task'
            get 'drain_status'
          end
        end
      end
    end
  end

  match "/info" => "api/cli/v1/api#info"

  root :to => "apps#index"
end
