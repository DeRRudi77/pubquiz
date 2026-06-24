module Games
  class SetupTeams < ApplicationInteraction
    object :game

    def execute
      game.team_setup!
      assign_players_to_teams
      game.broadcast_reload_teams
      game.broadcast_redirect_players_to_teams
    end

    private

    def assign_players_to_teams
      players = game.players.shuffle
      teams = game.teams.to_a
      players.each_with_index do |player, index|
        team = teams[index % teams.length]
        if index < teams.length
          player.update(team_id: team.id, team_captain: true)
        else
          player.update(team_id: team.id, team_captain: false)
        end
      end
    end
  end
end
