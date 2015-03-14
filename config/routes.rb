Rails.application.routes.draw do

  resources :days
  resources :tasks
  resources :people
  resources :duties do
    collection do
      post :destroy
    end
  end

  root to: 'planning#show'

end
