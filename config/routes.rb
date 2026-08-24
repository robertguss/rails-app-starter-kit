Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "ready" => "readiness#show"
  get "health" => "health#show"

  get "states/empty" => "states#empty"
  get "states/loading" => "states#loading"

  resources :round_trip_messages, only: :create

  root "home#show"

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "*path", to: "errors#not_found", via: :all
end
