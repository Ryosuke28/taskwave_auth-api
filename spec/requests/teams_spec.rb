require 'rails_helper'
require 'requests/shared'

RSpec.describe "Teams", type: :request do
  include_context '権限デフォルトデータ作成'

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
        expect(team.reload).to have_attributes(team_params)
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

  describe 'POST /api/v1/teams/:id/add_user' do
    subject { post add_user_api_v1_team_path(id: id), params: { user: user_params } }

    let(:action_name) { 'メンバー登録処理' }
    let(:en_action_name) { 'Member registration process' }
    let(:team) { create(:team) }
    let(:users) { create_list(:user, 4) }
    let(:id) { team.id }

    before do
      team
      users
    end

    let(:user_params) do
      [
        { email: users[0].email, authority_id: 1 },
        { email: users[1].email, authority_id: 2 },
        { email: users[2].email, authority_id: 3 }
      ]
    end

    context 'パラメータが揃っている場合' do
      it 'メンバーが登録される' do
        is_expected.to eq 200
        expect(
          UserTeam.where(team_id: team.id).pluck(:user_id, :authority_id)
        ).to match_array [[users[0].id, 1], [users[1].id, 2], [users[2].id, 3]]
      end
    end

    context '不正なパラメータの場合' do
      before { UserTeam.create(user_id: users[3].id, team_id: team.id, authority_id: 1) }

      let(:user_params) do
        [
          { email: users[0].email, authority_id: 1 },                      # 登録可能
          { email: 'unexist_address@test.test', authority_id: 1 },         # 存在しないメールアドレス
          { email: nil, authority_id: 2 },                                 # メールアドレスが空
          { email: users[1].email, authority_id: Authority.last.id.next }, # 存在しない権限ID
          { email: users[2].email, authority_id: nil },                    # 権限IDが空
          { email: users[3].email, authority_id: 2 }                       # 登録済みメールアドレスで登録
        ]
      end
      let(:error_code) { 'UAM_020401' }
      let(:error_messages) do
        ["アドレス：unexist_address@test.test,#{users[1].email},#{users[2].email},#{users[3].email}の招待に失敗しました"]
      end
      let(:en_error_messages) do
        ["Invitation failed unexist_address@test.test,#{users[1].email},#{users[2].email},#{users[3].email}"]
      end

      it_behaves_like '正しいエラーを返す', 400
      it '登録可能なものは登録される' do
        is_expected.to eq 400
        expect(
          UserTeam.where(team_id: team.id, user_id: users[0].id).pluck(:user_id, :authority_id)
        ).to match_array [[users[0].id, 1]]
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

  describe 'POST /api/v1/teams/:id/update_authority' do
    subject { post update_authority_api_v1_team_path(id: id), params: { user: user_params } }

    let(:action_name) { 'メンバー権限更新処理' }
    let(:en_action_name) { 'Member authority update process' }
    let(:team) { create(:team) }
    let(:user) { create(:user) }
    let(:id) { team.id }

    before do
      team
      user
      UserTeam.create(user_id: user.id, team_id: team.id, authority_id: 1)
    end

    let(:user_params) { { user_id: user.id, authority_id: 2 } }

    context 'パラメータが揃っている場合' do
      it 'メンバー権限が更新される' do
        is_expected.to eq 200
        expect(
          UserTeam.where(team_id: team.id, user_id: user.id).pluck(:user_id, :authority_id)
        ).to match_array [[user.id, 2]]
      end
    end

    context '不正なパラメータの場合' do
      context 'ユーザーが存在しない場合' do
        let(:user_params) { { user_id: User.last.id.next, authority_id: 2 } }
        let(:error_code) { 'UAM_000001' }
        let(:error_messages) { ['チームは存在しません'] }
        let(:en_error_messages) { ["Team not found"] }

        it_behaves_like '正しいエラーを返す', 404
      end

      context '権限IDが存在しない場合' do
        let(:user_params) { { user_id: user.id, authority_id: Authority.last.id.next } }
        let(:error_code) { 'UAM_030501' }
        let(:error_messages) { ['メンバーの権限更新に失敗しました'] }
        let(:en_error_messages) { ['Failed to update member authority'] }

        it_behaves_like '正しいエラーを返す', 400
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

  describe 'POST /api/v1/teams/:id/delete_user' do
    subject { post delete_user_api_v1_team_path(id: id), params: { user: user_params } }

    let(:action_name) { 'メンバー除外処理' }
    let(:en_action_name) { 'Member deletion process' }
    let(:team) { create(:team) }
    let(:user) { create(:user) }
    let(:id) { team.id }

    before do
      team
      user
      UserTeam.create(user_id: user.id, team_id: team.id, authority_id: 1)
    end

    let(:user_params) { { user_id: user.id } }

    context 'パラメータが揃っている場合' do
      it 'メンバーが除外される' do
        expect { subject }.to change(UserTeam, :count).by(-1)
        is_expected.to eq 200
      end
    end

    context '不正なパラメータの場合' do
      let(:user_params) { { id: User.last.id.next } }

      it '存在しないユーザーIDでも成功レスポンスを返す' do
        is_expected.to eq 200
        expect { subject }.not_to change(UserTeam, :count)
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
end
