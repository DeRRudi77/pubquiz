require "test_helper"

module Games
  class ProcessResultsTest < ActiveSupport::TestCase
    setup { @owner = users(:owner) }

    test "finishes the current round and moves the game to pending_results" do
      game = @owner.games.create!(name: "Pending", number_of_rounds: 2, number_of_teams: 1)
      Games::StartGame.run!(game: game)

      Games::ProcessResults.run!(game: game)

      assert game.reload.pending_results?
      assert game.rounds.find_by(number: 1).finished?
    end

    test "raises when given an invalid input" do
      assert_raises(ActiveInteraction::InvalidInteractionError) do
        Games::ProcessResults.run!(game: nil)
      end
    end
  end
end
