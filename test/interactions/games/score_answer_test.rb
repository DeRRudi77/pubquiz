require "test_helper"

module Games
  class ScoreAnswerTest < ActiveSupport::TestCase
    setup do
      @owner = users(:owner)
      @game = @owner.games.create!(name: "Scorable", number_of_rounds: 1, number_of_teams: 1)
      Games::StartGame.run!(game: @game)
      @round = @game.rounds.first
      @team = @game.teams.first
      @answers = @team.answers_for_round(@round).to_a
    end

    test "sets points on the answer" do
      Games::ScoreAnswer.run!(team_answer: @answers.first, points: 3)

      assert_equal 3, @answers.first.reload.points
    end

    test "scoring a non-final answer leaves the round unscored" do
      Games::ScoreAnswer.run!(team_answer: @answers.first, points: 1)

      refute @round.reload.scored?
    end

    test "scoring the last answer scores the round and updates team total" do
      @answers.each { |answer| Games::ScoreAnswer.run!(team_answer: answer, points: 2) }

      assert @round.reload.scored?
      assert_equal @answers.size * 2, @team.reload.total_points
    end

    test "does not re-score an already scored round" do
      @answers.each { |answer| Games::ScoreAnswer.run!(team_answer: answer, points: 2) }
      total_after_first_pass = @team.reload.total_points

      # Re-running on an answer in a scored round must not double-count.
      Games::ScoreAnswer.run!(team_answer: @answers.first, points: 5)

      assert_equal total_after_first_pass, @team.reload.total_points
    end

    test "raises when given an invalid input" do
      assert_raises(ActiveInteraction::InvalidInteractionError) do
        Games::ScoreAnswer.run!(team_answer: nil, points: 1)
      end
    end
  end
end
