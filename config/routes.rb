Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      resources :users, only: [:create]
      resources :teams, only: [:create, :edit, :update, :index] do
        collection do
          get 'count'
        end
      end

      devise_for :users, skip: :all
      # devise_scope :user do
      #   get 'users/testaa', to: 'users/registrations#testaa'
      # end

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
