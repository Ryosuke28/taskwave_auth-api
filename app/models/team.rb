class Team < ApplicationRecord
  validates :name, presence: true, length: { maximum: 32 }
  validates :description, length: { maximum: 256 }, allow_blank: true
end
