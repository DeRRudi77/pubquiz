require "test_helper"

module Games
  class ShowResultsTest < ActiveSupport::TestCase
    setup { @owner = users(:owner) }

    test "finishes the game and recomputes team totals" do
      game = @owner.games.create!(name: "Final", number_of_rounds: 1, number_of_teams: 1)
      Games::StartGame.run!(game: game)
      team = game.teams.first
      team.team_answers.update_all(points: 2)

      Games::ShowResults.run!(game: game)

      assert game.reload.finished?
      assert_equal team.team_answers.count * 2, team.reload.total_points
    end

    test "raises when given an invalid input" do
      assert_raises(ActiveInteraction::InvalidInteractionError) do
        Games::ShowResults.run!(game: nil)
      end
    end
  end
end
