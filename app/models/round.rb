class Round < ApplicationRecord
  belongs_to :game

  enum status: %i[pending_start started finished], _default: :pending_start

  validates :number_of_questions, numericality: { less_than_or_equal_to: 10 }, allow_nil: true

  has_many :answers, dependent: :destroy do
    def for_team(team)
      find_or_create_by(team: team)
    end
  end

  def next_round
    game.rounds.find_by(number: number + 1)
  end

  def progress
    100 / (game.number_of_rounds + 1) * number
  end
end
