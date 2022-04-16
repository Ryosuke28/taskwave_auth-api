module Api
  module V1
    class TeamsController < ApplicationController
      before_action :find_team, only: [:edit, :update]

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
        render_json @team.hash_for_display
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

      private

      def team_params
        params.require(:team).permit(:name, :description, :personal_flag)
      end

      def find_team
        @team = Team.find(params[:id])
      end
    end
  end
end
