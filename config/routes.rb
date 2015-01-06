Rails.application.routes.draw do
  require 'sidekiq/web'

  # Admin sections
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web, at: '/sidekiq'
    get 'admin/dashboard'
    post 'admin/check_all_w000ts'
    post 'admin/check_url'
    post 'admin/reset_sidekiq_stat'
  end

  # Hack for workflow_ios
  get 'workflow_ios/w000ts' => 'w000ts#create'

  # Public wall
  get 'public/wall' => 'w000ts#public_wall'

  # Users
  devise_for :users
  get '/users' => 'users#index'
  resources :users, param: :pseudo, only: [] do
    resources :authentication_tokens, path: :tokens
    get '/'           => 'users#show'
    get '/wall'       => 'w000ts#user_wall'
    get '/dashboard'  => 'user_dashboard#show'
  end

  # Personnal w000ts
  get '/w000ts/me'          => 'w000ts#owner_list'
  get '/w000ts/me/:type'    => 'w000ts#owner_list', as: 'w000ts_me_by_type'
  get '/w000ts/meme'        => 'w000ts#owner_wall'

  # w000ts and tokens
  resources :w000ts, param: :short_url, except: [:edit]
  # w000ts redirections
  get '/:short_url/click'   => 'w000ts#click', as: :w000t_click
  get '/:short_url'         => 'w000ts#redirect', as: :w000t_redirect

  # Default route
  root 'w000ts#new'

end
