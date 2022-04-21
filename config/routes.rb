Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      resources :users, only: [:create, :edit, :update]
      resources :teams, only: [:create, :edit, :update, :index] do
        collection do
          get 'count'
          get 'user_authority'
        end
        member do
          post 'add_user'
          post 'delete_user'
          post 'update_authority'
        end
      end

      devise_for :users, skip: :all

      get 'users/test'

      post 'auth_user' => 'authentication#authenticate_user'
    end
  end

  # devise_for :users, only: []
  # devise_for :users, controllers: {
  #   registrations: 'users/registrations'
  # }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
