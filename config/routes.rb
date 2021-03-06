Rails.application.routes.draw do
  devise_for :users
  root to: 'games#index'
  resources :questions
  resources :rounds, only: [:edit, :update]
  resources :games do
    member do
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
