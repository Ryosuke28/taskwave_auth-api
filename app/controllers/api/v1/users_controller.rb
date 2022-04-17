module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_request!, only: [:show]
      before_action :find_user, only: [:edit, :update]

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

      # ユーザー詳細
      # GET /api/v1/users/:id/edit
      def edit
        render_json @user.hash_for_edit
      end

      # ユーザー更新
      # PATCH /api/v1/users/:id
      def update
        @user.assign_attributes(user_params)

        if @user.save
          render_json @user
        else
          render problem: {
            title: I18n.t('action.users.update'),
            error_code: 'UAM_020301',
            error_message: @user.errors.full_messages
          }, status: :bad_request
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :alias, :email, :password, :password_confirmation)
      end

      def find_user
        @user = User.find(params[:id])
      end
    end
  end
end
