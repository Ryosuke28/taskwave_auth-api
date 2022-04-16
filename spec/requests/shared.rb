# RSpec.shared_context :presence_validation do |type, expected|
#   let(:actual) { build(factory, attribute => value) }

#   context (type == :nil ? 'nil' : 'empty') do
#     let(:value) { type == :nil ? nil : '' }
#     it { expect(actual).to (expected ? be_valid : be_invalid) }
#   end
# end

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
