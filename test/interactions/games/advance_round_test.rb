require "test_helper"

module Games
  class AdvanceRoundTest < ActiveSupport::TestCase
    setup { @owner = users(:owner) }

    test "advances to the next round and finishes the current one" do
      game = @owner.games.create!(name: "Multi", number_of_rounds: 3, number_of_teams: 1)
      Games::StartGame.run!(game: game)

      Games::AdvanceRound.run!(game: game)

      assert_equal 2, game.reload.current_round_number
      assert game.rounds.find_by(number: 1).finished?
      assert game.rounds.find_by(number: 2).started?
    end

    test "starts the game when it has not started yet" do
      game = @owner.games.create!(name: "Cold", number_of_rounds: 2, number_of_teams: 1)

      Games::AdvanceRound.run!(game: game)

      assert game.reload.started?
    end

    test "does not advance past the final round" do
      game = @owner.games.create!(name: "Last", number_of_rounds: 1, number_of_teams: 1)
      game.update_columns(status: Game.statuses[:started], current_round_number: 1)

      assert_nothing_raised { Games::AdvanceRound.run!(game: game) }
      assert_equal 1, game.reload.current_round_number, "should not advance past the last round"
    end

    test "raises when given an invalid input" do
      assert_raises(ActiveInteraction::InvalidInteractionError) do
        Games::AdvanceRound.run!(game: nil)
      end
    end
  end
end
