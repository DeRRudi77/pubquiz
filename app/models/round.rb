class Round < ApplicationRecord
  include RelationshipUpdatable

  belongs_to :game
  has_many :questions, -> { order(:number) }, dependent: :destroy
  has_many :team_answers, through: :questions

  enum status: %i[pending_start started finished scored], _default: :pending_start

  after_create :create_questions

  accepts_nested_attributes_for :questions

  def name
    "Round #{number}: #{title}"
  end

  def next_round
    game.rounds.find_by(number: number + 1)
  end

  def progress
    100 / (game.number_of_rounds + 1) * number
  end

  def all_answers_scored?
    team_answers.where(points: nil).count.zero?
  end

  private

  def create_questions
    update_relationship_to_amount(questions, 10)
  end
end

# == Schema Information
#
# Table name: rounds
#
#  id         :uuid             not null, primary key
#  name       :string
#  number     :integer          not null
#  status     :integer          default("pending_start")
#  title      :string
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
