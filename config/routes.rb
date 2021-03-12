Rails.application.routes.draw do
  resources :questions
  resources :rounds, only: [ :edit, :update ]
  resources :games do
    member do
      patch 'start'
      patch 'next_round'
      patch 'finish'
      patch 'show_results'
    end
  end
  resources :admins, only: :index
  resources :teams, only: [:show, :update, :edit]
  resources :team_answers, only: [:create, :update]
end
