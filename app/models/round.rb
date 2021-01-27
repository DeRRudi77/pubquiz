class Round < ApplicationRecord
  belongs_to :game

  enum status: %i[pending_start started finished], _default: :pending_start

  has_many :answers, dependent: :destroy do
    def for_team(team)
      find_or_create_by(team: team)
    end
  end

  validates :number_of_questions, presence: true

  def next_round
    game.rounds.find_by(number: number + 1)
  end
end
