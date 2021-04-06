Rails.application.routes.draw do
  resources :questions
  resources :rounds, only: [:edit, :update]
  resources :games do
    member do
      patch "start"
      patch "next_round"
      patch "process_results"
      patch "show_results"
    end
  end
  resources :teams, only: [:show, :update, :edit]
  resources :team_answers, only: [:create, :update]
end
