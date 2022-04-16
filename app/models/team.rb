class Team < ApplicationRecord
  validates :name, presence: true, length: { maximum: 32 }
  validates :description, length: { maximum: 256 }, allow_blank: true

  def hash_for_display
    {
      id: id,
      name: name,
      description: description,
      personal_flag: personal_flag,
      created_at: created_at.iso8601,
      updated_at: updated_at.iso8601
    }
  end
end
