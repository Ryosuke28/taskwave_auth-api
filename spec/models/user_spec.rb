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
        it_behaves_like '上限値の確認', 32, 'アカウント名は32文字以内で入力してください' do
          let(:name) { target_column }
        end

        it_behaves_like '下限値の確認', 'アカウント名は1文字以上で入力してください' do
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
        it_behaves_like '上限値の確認', 32, 'アカウント別名は32文字以内で入力してください' do
          let(:user_alias) { target_column }
        end

        context '下限値の場合' do
          let(:user_alias) { '' }

          it_behaves_like :valid_true
        end
      end
    end

    describe 'email' do
      context '桁数' do
        context '上限値の場合' do
          let(:email) { "#{'a' * 20}@example.com" }

          it_behaves_like :valid_true
        end

        context '上限値 +1 の場合' do
          let(:email) { "#{'a' * 21}@example.com" }

          it_behaves_like :valid_false, 'メールアドレスは32文字以内で入力してください'
        end
      end
    end
  end
end
