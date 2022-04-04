module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_request!, only: [:show]
      def show
        render json: { 'show method' => true }
      end

      def test
        user = User.first

        render_json(user)
      end
    end
  end
end
