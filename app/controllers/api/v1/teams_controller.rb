module Api
  module V1
    class TeamsController < ApplicationController
      before_action :find_team, only: [:edit, :update, :add_user, :update_authority, :delete_user]

      # チーム作成
      # POST /api/v1/teams
      # コントローラ番号：02
      def create
        team = Team.new(team_params)

        if team.save
          render_json team
        else
          render problem: {
            title: I18n.t('action.teams.create'),
            error_code: 'UAM_020001',
            error_message: team.errors.full_messages
          }, status: :bad_request
        end
      end

      # チーム詳細
      # GET /api/v1/teams/:id/edit
      def edit
        render_json @team.hash_for_edit
      end

      # チーム更新
      # POST /api/v1/teams/:id
      def update
        @team.assign_attributes(team_params)

        if @team.save
          render_json @team
        else
          render problem: {
            title: I18n.t('action.teams.update'),
            error_code: 'UAM_020301',
            error_message: @team.errors.full_messages
          }, status: :bad_request
        end
      end

      # チーム一覧
      # GET /api/v1/teams
      def index
        @teams = Team.all

        render_json @teams.map(&:hash_for_index)
      end

      # チーム数
      # GET /api/v1/teams/count
      def count
        render_json Team.count
      end

      # rubocop:disable Metrics/AbcSize
      # チームにユーザー登録
      # GET /api/v1/teams/:id/add_user
      def add_user
        errors_address = []

        user_params.each do |user_param|
          user = User.find_by(email: user_param[:email])
          user_team = UserTeam.new(user_id: user&.id, team_id: @team.id, authority_id: user_param[:authority_id])
          errors_address.push(user_param[:email]) if !user_team.save && user_param[:email].present?
        end

        if errors_address.blank?
          render_json({})
        else
          render_problem('UAM_020401',
                         [I18n.t('activerecord.errors.messages.failed_to_add_user', email: errors_address.join(','))])
        end
      end
      # rubocop:enable Metrics/AbcSize

      # チームユーザーの権限変更
      # GET /api/v1/teams/:id/update_authority
      def update_authority
        user_team = UserTeam.find_by(user_id: params.dig(:user, :user_id), team_id: @team.id)
        raise ActiveRecord::RecordNotFound if user_team.nil?

        user_team.authority_id = params.dig(:user, :authority_id)

        if user_team.save
          render_json({})
        else
          render_problem('UAM_030501', [I18n.t('activerecord.errors.messages.failed_to_update_authority')])
        end
      end

      # チームからユーザー削除
      # GET /api/v1/teams/:id/delete_user
      def delete_user
        user_team = UserTeam.find_by(user_id: params.dig(:user, :user_id), team_id: @team.id)

        if user_team.nil? || user_team.delete
          render_json({})
        else
          render_problem('UAM_020501', [I18n.t('activerecord.errors.messages.failed_to_delete_user')])
        end
      end

      private

      def team_params
        params.require(:team).permit(:name, :description, :personal_flag)
      end

      def user_params
        params.require(:user).map { |user| user.permit(:email, :authority_id) }
      end

      def find_team
        @team = Team.find(params[:id])
      end
    end
  end
end
