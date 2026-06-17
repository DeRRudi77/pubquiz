module Games
  class ProcessResults < ApplicationInteraction
    object :game

    def execute
      game.current_round.finished!
      game.pending_results! unless game.pending_results?
      game.broadcast_reload_teams
    end
  end
end
