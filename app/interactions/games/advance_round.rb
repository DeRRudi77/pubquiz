module Games
  class AdvanceRound < ApplicationInteraction
    object :game

    def execute
      game.started! unless game.started?
      game.current_round&.finished!
      return unless game.next_round.present?
      game.next_round.started!
      game.update!(current_round_number: game.current_round_number + 1)
      game.broadcast_reload_teams
    end
  end
end
