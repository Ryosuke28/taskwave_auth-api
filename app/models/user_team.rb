class UserTeam < ApplicationRecord
  belongs_to :user
  belongs_to :team
  belongs_to :authority

  validates :authority, presence: true
  validates :user_id, uniqueness: { scope: :team }
end
