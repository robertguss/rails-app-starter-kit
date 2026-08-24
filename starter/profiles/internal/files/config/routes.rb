Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "ready" => "readiness#show"
  get "health" => "health#show"

  get "states/empty" => "states#empty"
  get "states/loading" => "states#loading"

  resources :round_trip_messages, only: :create

  get "login" => "sessions#new"
  delete "logout" => "sessions#destroy"
  get "/auth/google_oauth2/callback" => "omniauth_callbacks#google"
  get "/auth/failure" => "omniauth_callbacks#failure"
  post "agent/login" => "agent_sessions#create"
  get "settings/access" => "settings/access#index", as: :settings_access
  post "settings/access" => "settings/access#create"
  delete "settings/access/:id" => "settings/access#destroy"
  post "settings/access/:id/transfer" => "settings/access#transfer"

  resources :operations, only: %i[index create show] do
    get :status, on: :member
  end

  root "home#show"

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "*path", to: "errors#not_found", via: :all
end
