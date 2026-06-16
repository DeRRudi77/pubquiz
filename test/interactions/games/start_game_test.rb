require "test_helper"

module Games
  class StartGameTest < ActiveSupport::TestCase
    setup do
      @owner = users(:owner)
      @game = @owner.games.create!(name: "Startable", number_of_rounds: 2, number_of_teams: 2)
    end

    test "transitions the game and its first round to started" do
      Games::StartGame.run!(game: @game)

      assert @game.reload.started?
      assert @game.rounds.first.started?
      assert_equal 1, @game.current_round_number
    end

    test "ensures a team answer exists for every question and team" do
      Games::StartGame.run!(game: @game)

      @game.rounds.each do |round|
        round.questions.each do |question|
          @game.teams.each do |team|
            assert question.team_answers.exists?(team: team),
              "expected a TeamAnswer for question #{question.number} / team #{team.number}"
          end
        end
      end
    end

    test "raises when given an invalid input" do
      assert_raises(ActiveInteraction::InvalidInteractionError) do
        Games::StartGame.run!(game: nil)
      end
    end
  end
end
