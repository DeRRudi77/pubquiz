module Games
  class ScoreAnswer < ApplicationInteraction
    object :team_answer, class: TeamAnswer
    float :points, default: nil

    def execute
      team_answer.update!(points: points)
      score_round_if_complete
      team_answer
    end

    private

    def score_round_if_complete
      round = team_answer.round.reload
      return if round.scored?
      return unless round.all_answers_scored?
      round.scored!
      team_answer.team.update_total_points!
    end
  end
end
