module Api
  module V1
    class AuthenticationController < ApplicationController
      def authenticate_user
        user = User.find_for_database_authentication(email: params[:email])
        if user.present?
          render json: payload(user)
        else
          render json: { errors: ['Invalid Username/Password'] }, status: :unauthorized
        end
      end

      private

      def payload(user)
        return nil unless user&.id

        payload = {
          user_id: user.id,
          exp: (Time.now + 2.week).to_i
        }

        {
          auth_token: JsonWebToken.encode(payload),
          user: { id: user.id, email: user.email }
        }
      end
    end
  end
end
