class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_teams
  has_many :teams, through: :user_teams

  validates :name, presence: true, length: { maximum: 50 }
  validates :alias, length: { maximum: 50 }, allow_blank: true
  validates :email, length: { maximum: 256 }

  after_create :create_personal_team

  # ユーザー詳細用のハッシュに整形する
  # @return [Hash] ユーザー情報
  def hash_for_edit
    {
      id: id,
      name: name,
      alias: self.alias,
      email: email,
      created_at: created_at.iso8601,
      updated_at: updated_at.iso8601
    }
  end

  private

  def create_personal_team
    time = Time.zone.now.strftime("%Y%m%d%H%M%S")

    team = Team.create(name: "#{name}_team#{time}", description: '', personal_flag: true)
    UserTeam.create(user_id: id, team_id: team.id, authority_id: 3)
  end
end
