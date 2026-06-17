module Games
  class ShowResults < ApplicationInteraction
    object :game

    def execute
      game.finished! unless game.finished?
      game.teams.each(&:update_total_points!)
      game.broadcast_reload_teams
    end
  end
end
