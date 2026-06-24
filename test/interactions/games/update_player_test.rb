require "test_helper"

module Games
  class UpdatePlayerTest < ActiveSupport::TestCase
    include Turbo::Broadcastable::TestHelper

    setup do
      @owner = users(:owner)
      @game = @owner.games.create!(name: "Joinable", number_of_rounds: 2, number_of_teams: 2)
      @player = Player.new(session_id: "session-1", game_id: @game.id)
    end

    test "updates the player name and broadcasts a replace to the game stream" do
      streams = capture_turbo_stream_broadcasts(@game) do
        outcome = Games::UpdatePlayer.run(player: @player, name: "Ada")

        assert outcome.valid?
        assert_equal "Ada", @player.name
      end

      assert_equal 1, streams.size
      assert_equal "replace", streams.first["action"]
    end

    test "is invalid and does not broadcast when the name is blank" do
      streams = capture_turbo_stream_broadcasts(@game) do
        outcome = Games::UpdatePlayer.run(player: @player, name: "")

        assert outcome.invalid?
        assert_includes outcome.errors[:name], "can't be blank"
      end

      assert_empty streams
    end
  end
end
