Rails.application.routes.draw do

  resources :days
  resources :tasks
  resources :people
  resources :duties do
    collection do
      post :delete
    end
  end

  root to: 'planning#show'

end
