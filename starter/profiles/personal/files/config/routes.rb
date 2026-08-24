Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "ready" => "readiness#show"
  get "health" => "health#show"

  get "states/empty" => "states#empty"
  get "states/loading" => "states#loading"

  resources :round_trip_messages, only: :create

  get "login" => "sessions#new"
  post "login" => "sessions#create"
  delete "logout" => "sessions#destroy"
  get "invitations/:token" => "invitations#show", as: :invitation
  patch "invitations/:token" => "invitations#update"
  resource :password_recovery, only: %i[new create update]
  get "password_recovery/:token" => "password_recoveries#edit", as: :edit_password_recovery
  post "agent/login" => "agent_sessions#create"
  get "settings/access" => "settings/access#index", as: :settings_access
  post "settings/access" => "settings/access#create"
  delete "settings/access/:id" => "settings/access#destroy"
  post "settings/access/:id/transfer" => "settings/access#transfer"

  root "home#show"

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "*path", to: "errors#not_found", via: :all,
    constraints: ->(request) { !request.path.start_with?(ActiveStorage.routes_prefix) }
end
