class Round < ApplicationRecord
  belongs_to :game
  enum status: %i[started ended], _default: "started"

  has_many :answers, dependent: :destroy do
    def for_team(team)
      find_or_create_by(team: team)
    end
  end

  scope :ended , -> { where(ended: true)}

  def round_number
    "#{game.rounds.ended.count + 1}"
  end
end
