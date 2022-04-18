class Team < ApplicationRecord
  has_many :user_teams
  has_many :users, through: :user_teams

  validates :name, presence: true, length: { maximum: 32 }
  validates :description, length: { maximum: 256 }, allow_blank: true

  # チーム詳細用のハッシュに整形する
  # @return [Hash] チーム情報
  def hash_for_edit
    {
      id: id,
      name: name,
      description: description,
      personal_flag: personal_flag,
      created_at: created_at.iso8601,
      updated_at: updated_at.iso8601
    }
  end

  # チーム一覧用のハッシュに整形する
  # @return [Hash] チーム情報
  def hash_for_index
    {
      id: id,
      name: name,
      description: description,
      personal_flag: personal_flag
    }
  end
end
