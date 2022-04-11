require 'rails_helper'
require 'requests/shared'

RSpec.describe "Teams", type: :request do
  describe 'POST /api/v1/teams' do
    subject { post api_v1_teams_path, params: { team: team_params } }

    let(:action_name) { 'チーム作成処理' }
    let(:en_action_name) { 'Team creation process' }

    let(:team_params) do
      {
        name: name,
        description: description,
        personal_flag: personal_flag
      }
    end
    let(:name) { 'test1' }
    let(:description) { 'test1_description' }
    let(:personal_flag) { true }

    shared_examples 'チームは登録されない' do
      it { expect { subject }.not_to change(Team, :count) }
    end

    context 'パラメータが揃っている場合' do
      it 'チームが登録される' do
        expect { subject }.to change(Team, :count).by(1)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'パラメータが不足している場合' do
      let(:name) { '' }
      let(:error_code) { 'UAM_020001' }
      let(:error_messages) { ['チーム名を入力してください'] }
      let(:en_error_messages) { ["Name can't be blank"] }

      it_behaves_like 'チームは登録されない'
      it_behaves_like '正しいエラーを返す', 400
    end
  end
end
