Rails.application.routes.draw do
  devise_for :users
  root to: "games#index"
  resources :rounds, only: [:edit, :update] do
    resources :questions, only: [:create], module: :rounds
  end
  resources :questions, only: [:destroy], module: :rounds
  resources :games do
    resource :player, only: [:update], module: :games
    member do
      patch "setup_teams"
      patch "start"
      patch "next_round"
      patch "process_results"
      patch "show_results"
      get "join"
    end
  end
  resources :teams, only: [:show, :update]
  resources :team_answers, only: [:update]
end
