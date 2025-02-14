Rails.application.routes.draw do
  root "sessions#new"

  get "signup", to: "users#new"      # Route to show sign-up form
  post "signup", to: "users#create"  # Route to handle form submission

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  get "logout", to: "sessions#destroy"  # Temporary GET logout route
  delete "logout", to: "sessions#destroy"

  resources :tickets
  resources :screens, only: [] do
    get "capacity", on: :member
  end
  resources :movies do
    resources :shows
  end
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
