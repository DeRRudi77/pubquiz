class Team < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :game
  has_many :team_answers

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
#  game_id    :uuid             not null
#
# Indexes
#
#  index_teams_on_game_id  (game_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
