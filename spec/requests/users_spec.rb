require 'rails_helper'
require 'requests/shared'

RSpec.describe "Users", type: :request do
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

  xdescribe "GET /show" do
    it "returns http success" do
      get "/users/show"
      expect(response).to have_http_status(:success)
    end
  end
end
