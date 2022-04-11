require 'rails_helper'
require 'models/shared'

RSpec.describe Team, type: :model do
  describe 'valid' do
    subject { model.valid? }

    let(:model) { build(:team, name: name, description: description, personal_flag: personal_flag) }
    let(:name) { 'sample_name' }
    let(:description) { '' }
    let(:personal_flag) { true }

    describe 'name' do
      context '桁数' do
        it_behaves_like '上限値の確認', 32, 'チーム名は32文字以内で入力してください' do
          let(:name) { target_column }
        end
      end

      context '必須入力' do
        it_behaves_like '必須入力の確認', 'チーム名を入力してください' do
          let(:name) { target_column }
        end
      end
    end

    describe 'description' do
      context '桁数' do
        it_behaves_like '上限値の確認', 256, '説明は256文字以内で入力してください' do
          let(:description) { target_column }
        end
      end
    end
  end
end
