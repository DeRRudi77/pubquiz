class Round < ApplicationRecord
  include RelationshipUpdatable

  belongs_to :game
  has_many :questions, -> { order(:number) }, dependent: :destroy

  enum status: %i[pending_start started finished], _default: :pending_start

  validates :number_of_questions, numericality: { less_than_or_equal_to: 10 }, allow_nil: true

  after_create :create_questions

  accepts_nested_attributes_for :questions

  has_many :team_answers, dependent: :destroy do
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

  private

  def update_questions
    update_relationship_to_amount(questions, 10)
  end
end

# == Schema Information
#
# Table name: rounds
#
#  id         :uuid             not null, primary key
#  number     :integer          not null
#  status     :integer          default("pending_start")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :uuid             not null
#
# Indexes
#
#  index_rounds_on_game_id  (game_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
