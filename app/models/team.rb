class Team < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :game

  has_many :team_answers
  has_many :current_round_answers, ->(team) { where(question: team.game.current_round.questions) }, class_name: 'TeamAnswer'

  validates_uniqueness_of :name, case_sensitive: false

  accepts_nested_attributes_for :team_answers

  def answers_for_current_round
    team_answers.where(question: game.current_round.questions)
  end

  # broadcasts
  after_update_commit -> do
    # broadcast_replace_to(game)
    game.reload.broadcast_replace_to game
  end
  # broadcasts_to(:game)

  def display_name(number)
    name || "Team #{number}"
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
#  game_id    :uuid             not nullg
#
# Indexes
#
#  index_teams_on_game_id  (game_id)
#  index_teams_on_name     (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
