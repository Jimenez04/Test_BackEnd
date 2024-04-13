Rails.application.routes.draw do
  get 'feature/index'
  get 'feature/get'
  get 'comment/create'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/api/features/mag/:mag_type/page/:page/per_page/:per_page", to: "feature#index"
  get "/api/features/page/:page/per_page/:per_page", to: "feature#index"
  get "/api/feature/id/:id", to: "feature#get"
  post "/api/feature/id/:id/comments/create", to: "comment#create"

  # Defines the root path route ("/")
  # root "posts#index"
end
