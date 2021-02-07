class Team < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :game
  has_many :answers

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
