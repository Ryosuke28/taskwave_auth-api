require 'rails_helper'
require 'requests/shared'

RSpec.describe "Users", type: :request do
  include_context '権限デフォルトデータ作成'

  describe 'POST /api/v1/users' do
    subject { post api_v1_users_path, params: { user: user_params } }

    let(:action_name) { 'ユーザー作成処理' }
    let(:en_action_name) { 'User creation process' }

    let(:user_params) do
      {
        name: name,
        email: email,
        password: password,
        password_confirmation: password_confirmation
      }
    end
    let(:name) { 'test1' }
    let(:email) { 'test1@example.com' }
    let(:password) { 'password' }
    let(:password_confirmation) { 'password' }

    shared_examples 'ユーザーは登録されない' do
      it { expect { subject }.not_to change(User, :count) }
    end

    context 'パラメータが揃っている場合' do
      it 'ユーザーが登録される' do
        expect { subject }.to change(User, :count).by(1)
        expect(response).to have_http_status(:ok)
      end

      it '関連するインスタンスが登録される' do
        expect { subject }.to change(Team, :count).by(1).and change(UserTeam, :count).by(1)
      end
    end

    context 'パラメータが不足している場合' do
      let(:email) { '' }
      let(:error_code) { 'UAM_010001' }
      let(:error_messages) { ['メールアドレスを入力してください'] }
      let(:en_error_messages) { ["Email address can't be blank"] }

      it_behaves_like 'ユーザーは登録されない'
      it_behaves_like '正しいエラーを返す', 400
    end

    context 'パスワードとパスワード（確認）が一致しない場合' do
      let(:password) { 'password' }
      let(:password_confirmation) { 'password1' }
      let(:error_code) { 'UAM_010001' }
      let(:error_messages) { ['パスワード（確認）とパスワードの入力が一致しません'] }
      let(:en_error_messages) { ["Password confirmation doesn't match Password"] }

      it_behaves_like 'ユーザーは登録されない'
      it_behaves_like '正しいエラーを返す', 400
    end
  end

  describe 'GET /api/v1/users/:id/edit' do
    subject { get edit_api_v1_user_path(id: id) }

    let(:action_name) { 'ユーザー詳細取得処理' }
    let(:en_action_name) { 'User detail acquisition process' }

    let!(:user) { create(:user) }
    let(:id) { user.id }
    let(:expect_response) do
      {
        id: user.id,
        name: user.name,
        alias: user.alias,
        email: user.email,
        created_at: user.created_at.iso8601,
        updated_at: user.updated_at.iso8601
      }
    end

    context '存在するIDの場合' do
      it 'ユーザー情報が返却される' do
        subject
        expect(response).to have_http_status(:ok)
        expect(json_body).to eq expect_response
      end
    end

    context '存在しないIDの場合' do
      let(:id) { User.last.id.next }
      let(:error_code) { 'UAM_000001' }
      let(:error_messages) { ['ユーザーは存在しません'] }
      let(:en_error_messages) { ["User not found"] }

      it_behaves_like '正しいエラーを返す', 404
    end
  end

  describe 'GET /api/v1/users/:id' do
    subject { patch api_v1_user_path(id: id), params: { user: user_params } }

    let(:action_name) { 'ユーザー情報更新処理' }
    let(:en_action_name) { 'User information update process' }

    let!(:user) { create(:user) }
    let(:id) { user.id }
    let(:user_params) do
      {
        name: name,
        alias: alias_params,
        email: email,
        password: password,
        password_confirmation: password_confirmation
      }
    end
    let(:name) { 'changed_name' }
    let(:alias_params) { 'changed_alias' }
    let(:email) { 'changed_email@example.com' }
    let(:password) { 'changed_password' }
    let(:password_confirmation) { 'changed_password' }
    let(:expect_response) do
      {
        name: name,
        alias: user.alias,
        email: email
      }
    end

    context 'パラメータが揃っている場合' do
      it 'ユーザー情報が更新される' do
        is_expected.to eq 200
        expect(user.reload).to have_attributes(expect_response)
      end
    end

    context 'パラメータが不足している場合' do
      let(:name) { '' }
      let(:error_code) { 'UAM_020301' }
      let(:error_messages) { ['アカウント名を入力してください'] }
      let(:en_error_messages) { ["Account name can't be blank"] }

      it_behaves_like '正しいエラーを返す', 400
    end

    context '存在しないIDの場合' do
      let(:id) { User.last.id.next }
      let(:error_code) { 'UAM_000001' }
      let(:error_messages) { ['ユーザーは存在しません'] }
      let(:en_error_messages) { ["User not found"] }

      it_behaves_like '正しいエラーを返す', 404
    end
  end
end
