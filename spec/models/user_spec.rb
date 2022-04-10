require 'rails_helper'
require 'models/shared'

RSpec.describe User, type: :model do
  describe 'valid' do
    subject { model.valid? }

    let(:model) { build(:user, name: name, email: email, alias: user_alias) }
    let(:name) { 'sample_name' }
    let(:user_alias) { 'sample_alias' }
    let(:email) { 'sample1@sample.com' }

    describe 'name' do
      context '桁数' do
        it_behaves_like '上限値の確認', 50, 'アカウント名は50文字以内で入力してください' do
          let(:name) { target_column }
        end
      end

      context '必須入力' do
        it_behaves_like '必須入力の確認', 'アカウント名を入力してください' do
          let(:name) { target_column }
        end
      end
    end

    describe 'alias' do
      context '桁数' do
        it_behaves_like '上限値の確認', 50, 'アカウント別名は50文字以内で入力してください' do
          let(:user_alias) { target_column }
        end
      end
    end

    describe 'email' do
      context '桁数' do
        context '上限値の場合' do
          let(:email) { "#{'a' * 244}@example.com" }

          it_behaves_like :valid_true
        end

        context '上限値 +1 の場合' do
          let(:email) { "#{'a' * 245}@example.com" }

          it_behaves_like :valid_false, 'メールアドレスは256文字以内で入力してください'
        end
      end
    end
  end
end
