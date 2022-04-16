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

  describe 'GET /api/v1/teams/:id/edit' do
    subject { get edit_api_v1_team_path(id: id) }

    let(:action_name) { 'チーム詳細取得処理' }
    let(:en_action_name) { 'Team detail acquisition process' }

    let!(:team) { create(:team) }
    let(:id) { team.id }
    let(:expect_response) do
      {
        id: team.id,
        name: team.name,
        description: team.description,
        personal_flag: team.personal_flag,
        created_at: team.created_at.iso8601,
        updated_at: team.updated_at.iso8601
      }
    end

    context '存在するIDの場合' do
      it 'チーム情報が返却される' do
        subject
        expect(response).to have_http_status(:ok)
        expect(json_body).to eq expect_response
      end
    end

    context '存在しないIDの場合' do
      let(:id) { Team.last.id.next }
      let(:error_code) { 'UAM_000001' }
      let(:error_messages) { ['チームは存在しません'] }
      let(:en_error_messages) { ["Team not found"] }

      it_behaves_like '正しいエラーを返す', 404
    end
  end

  describe 'PATCh /api/v1/teams/:id' do
    subject { patch api_v1_team_path(id: id), params: { team: team_params } }

    let(:action_name) { 'チーム情報更新処理' }
    let(:en_action_name) { 'Team information update process' }
    let!(:team) { create(:team) }
    let(:id) { team.id }

    let(:team_params) do
      {
        name: name,
        description: description,
        personal_flag: personal_flag
      }
    end
    let(:name) { 'changed_name' }
    let(:description) { 'changed_description' }
    let(:personal_flag) { false }

    context 'パラメータが揃っている場合' do
      it 'チーム情報が更新される' do
        is_expected.to eq 200
        expect(team.reload.name).to eq name
        expect(team).to have_attributes(team_params)
      end
    end

    context 'パラメータが不足している場合' do
      let(:name) { '' }
      let(:error_code) { 'UAM_020301' }
      let(:error_messages) { ['チーム名を入力してください'] }
      let(:en_error_messages) { ["Name can't be blank"] }

      it_behaves_like '正しいエラーを返す', 400
    end

    context '存在しないIDの場合' do
      let(:id) { Team.last.id.next }
      let(:error_code) { 'UAM_000001' }
      let(:error_messages) { ['チームは存在しません'] }
      let(:en_error_messages) { ["Team not found"] }

      it_behaves_like '正しいエラーを返す', 404
    end
  end

  describe 'GET /api/v1/teams' do
    subject { get api_v1_teams_path }

    let(:action_name) { 'チーム一覧取得処理' }
    let(:en_action_name) { 'Team list acquisition process' }

    context 'チームが存在しない場合' do
      it '空配列を返す' do
        is_expected.to eq 200
        expect(json_array).to eq []
      end
    end

    context 'チームが存在する場合' do
      before do
        team_first
        team_second
      end
      let(:team_first) { create(:team) }
      let(:team_second) { create(:team) }
      let(:expect_response) do
        [
          {
            id: team_first.id,
            name: team_first.name,
            description: team_first.description,
            personal_flag: team_first.personal_flag
          }, {
            id: team_second.id,
            name: team_second.name,
            description: team_second.description,
            personal_flag: team_second.personal_flag
          }
        ]
      end

      it do
        is_expected.to eq 200
        expect(json_array).to eq expect_response
      end
    end
  end

  describe 'GET /api/v1/teams/count' do
    subject { get count_api_v1_teams_path }

    let(:action_name) { 'チーム数取得処理' }
    let(:en_action_name) { 'Team count acquisition process' }
    let!(:teams) { create_list(:team, 2) }

    context 'チームが存在する場合' do
      it 'チーム数を返す' do
        is_expected.to eq 200
        expect(response.body.to_i).to eq Team.count
      end
    end
  end
end
