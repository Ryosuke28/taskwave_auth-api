module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_request!, only: [:show]

      # ユーザー作成
      # POST /api/v1/users
      # コントローラ番号：01
      def create
        user = User.new(user_params)

        if user.save
          render_json user
        else
          render problem: {
            title: I18n.t('action.users.create'),
            error_code: 'UAM_010001',
            error_message: user.errors.full_messages
          }, status: :bad_request
        end
      end

      def show
        render json: { 'show method' => true }
      end

      def test
        user = User.first

        render_json(user)
      end

      private

      def user_params
        params.require(:user).permit(:name, :alias, :email, :password, :password_confirmation)
      end
    end
  end
end
