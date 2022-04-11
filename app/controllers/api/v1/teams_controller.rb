module Api
  module V1
    class TeamsController < ApplicationController
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

      private

      def team_params
        params.require(:team).permit(:name, :description, :personal_flag)
      end
    end
  end
end
