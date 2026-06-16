module Games
  class StartGame < ApplicationInteraction
    object :game

    def execute
      game.started!
      game.rounds.first.started!
      game.update!(current_round_number: 1)
      ensure_answers_exist
      game.broadcast_reload_teams
    end

    private

    def ensure_answers_exist
      game.rounds.each do |round|
        round.questions.each do |question|
          game.teams.each { |team| question.team_answers.for_team(team) }
        end
      end
    end
  end
end
