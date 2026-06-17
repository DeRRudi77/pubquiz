Rails.application.routes.draw do
  devise_for :users
  root to: "games#index"
  resources :questions, except: [:create]
  resources :rounds, only: [:edit, :update] do
    resources :questions, only: [:create]
  end
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
