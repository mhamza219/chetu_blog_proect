Rails.application.routes.draw do
  get "weather/index"
  require "sidekiq/web" # require the web UI

  Rails.application.routes.draw do
  get "weather/index"
    mount Sidekiq::Web => "/sidekiq" # access it at http://localhost:3000/sidekiq
  end
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
  
  resources :blogs do
    member do
      get :update_blog_status
    end
  end

  get "weather", to: "weather#index"

  get "turbo_frame_one", to: "turbo_frames#page_one"
  get "turbo_frame_two", to: "turbo_frames#page_two"

  resources :rooms do
    resources :messages
  end

  # post 'create_private_room/:user_id', to: 'rooms#create_private_room'

  # get "/blogs", to: "blog#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "blogs#index"
end
