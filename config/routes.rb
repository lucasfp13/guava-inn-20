Rails.application.routes.draw do
  resources :rooms
  resources :reservations, only: [:new, :create, :destroy] do
    get :new_search, on: :collection
    get :show_search, on: :collection
  end

  root to: redirect('/rooms')
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
