Rails.application.routes.draw do

  require "sidekiq/web" # require the web UI

  # get "orders/index"
  # get "orders/show"
  # get "payment_status_page/success"
  # get "payment_status_page/cancel"
  # get "weather/index"
    mount Sidekiq::Web => "/sidekiq" # access it at http://localhost:3000/sidekiq

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # devise_for :users
   devise_for :users, controllers: {
        sessions: 'users/sessions',
        registrations: 'users/registrations',
        passwords: 'users/passwords'
      }
  resources :blogs do
    member do
      get :update_blog_status
    end
  end

  resources :job_application_details do
    collection do
      post :parse_document
    end
  end


  get "weather", to: "weather#index"
  resource :profile, only: [:edit, :update]
  post "update_location", to: "users/locations#update", as: :update_user_location

  get "distance_calculator", to: "distance_calculator#index", as: :distance_calculator
  post "distance_calculator/calculate", to: "distance_calculator#calculate", as: :calculate_distance
  get "distance_calculator/search", to: "distance_calculator#search", as: :search_distance_location

  get "turbo_frame_one", to: "turbo_frames#page_one"
  get "turbo_frame_two", to: "turbo_frames#page_two"

  resources :rooms do
    resources :messages do
      member do
        post :read
      end
    end
  end

  resources :products
  
  # Cart routes
  resource :cart, only: [:show] do
    post 'add_item/:product_id', to: 'carts#add_item', as: :add_item
  end

  get 'checkout', to: 'checkouts#show', as: :checkout
  post 'checkout', to: 'checkouts#create'

  scope module: :payments do
    get 'stripe/checkout', to: 'stripe#checkout', as: :stripe_checkout
    post 'stripe/webhook',  to: 'stripe#webhook',  as: :stripe_webhook
    get 'stripe/checkout_mock', to: 'stripe#checkout_mock', as: :stripe_checkout_mock
    post 'stripe/checkout_mock_success', to: 'stripe#checkout_mock_success', as: :stripe_checkout_mock_success
    
    get 'cashfree/checkout', to: 'cashfree#checkout', as: :cashfree_checkout
    post 'cashfree/success', to: 'cashfree#success', as: :cashfree_success
    post 'cashfree/cancel',  to: 'cashfree#cancel',  as: :cashfree_cancel

    get 'razorpay/checkout', to: 'razorpay#checkout', as: :razorpay_checkout
    post 'razorpay/success', to: 'razorpay#success', as: :razorpay_success
    post 'razorpay/cancel',  to: 'razorpay#cancel',  as: :razorpay_cancel

    get 'billdesk/checkout', to: 'billdesk#checkout', as: :billdesk_checkout
    post 'billdesk/success', to: 'billdesk#success', as: :billdesk_success
    post 'billdesk/cancel',  to: 'billdesk#cancel',  as: :billdesk_cancel
  end

  resources :orders, only: [:index, :show]

  get 'success', to: 'payment_status_page#success', as: :success
  get 'cancel',  to: 'payment_status_page#cancel',  as: :cancel

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
  # root "blogs#index"
  root "products#index"
end
