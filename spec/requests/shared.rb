# RSpec.shared_context :presence_validation do |type, expected|
#   let(:actual) { build(factory, attribute => value) }

#   context (type == :nil ? 'nil' : 'empty') do
#     let(:value) { type == :nil ? nil : '' }
#     it { expect(actual).to (expected ? be_valid : be_invalid) }
#   end
# end
RSpec.shared_context '権限デフォルトデータ作成' do
  before do
    Authority.first_or_create([
                                { id: 1, name: 'normal', alias: '一般', description: '権限なし' },
                                { id: 2, name: 'admin', alias: '管理者', description: '全てのタスク作成・編集・削除、タスクのアサイン' },
                                { id: 3, name: 'owner', alias: '所有者', description: '管理者の権限全て、テーブルの削除' }
                              ])
  end
end

# action_name, error_code, error_messagesは事前に定義しておく
RSpec.shared_examples '正しいエラーを返す' do |status|
  context '日本語の場合' do
    it do
      subject
      expect(json_body[:title]).to eq action_name
      expect(json_body[:status]).to eq status
      expect(json_body[:error_code]).to eq error_code
      expect(json_body[:error_message]).to eq error_messages
    end
  end

  context '英語の場合' do
    around do |example|
      I18n.locale = :en
      example.run
      I18n.locale = :ja
    end

    it do
      subject
      expect(json_body[:title]).to eq en_action_name
      expect(json_body[:status]).to eq status
      expect(json_body[:error_code]).to eq error_code
      expect(json_body[:error_message]).to eq en_error_messages
    end
  end
end
