Rails.application.routes.draw do

  resources :days
  resources :tasks
  resources :people
  resources :duties

  root to: 'planning#show'

end
