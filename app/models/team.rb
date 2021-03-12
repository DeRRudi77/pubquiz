class Team < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :game

  has_many :team_answers
  has_many :current_round_answers, ->(team) { includes(:question).where(question: team.game.current_round.questions).order("questions.number asc") }, class_name: 'TeamAnswer'

  validates_uniqueness_of :name, case_sensitive: false

  accepts_nested_attributes_for :team_answers

  before_create :set_name

  def answers_for_current_round
    answers_for_round(game.current_round)
  end

  def answers_for_round(round)
    team_answers.where(question: round.questions)
  end

  def points_for_round(round)
    answers_for_round(round).sum(:points)
  end

  # broadcasts
  after_update_commit -> do
    # broadcast_replace_to(game)
    game.reload.broadcast_replace_to game
  end
  # broadcasts_to(:game)

  def display_name
    name || "Team #{number}"
  end

  def total_points
    team_answers.sum(:points)
  end

  private

  def set_name
    self.name = display_name
  end
end

# == Schema Information
#
# Table name: teams
#
#  id         :uuid             not null, primary key
#  name       :string
#  number     :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :uuid             not null
#
# Indexes
#
#  index_teams_on_game_id           (game_id)
#  index_teams_on_game_id_and_name  (game_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
