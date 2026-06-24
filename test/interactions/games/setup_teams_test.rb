require "test_helper"
require "minitest/mock"

module Games
  class SetupTeamsTest < ActiveSupport::TestCase
    include Turbo::Broadcastable::TestHelper

    setup do
      @owner = users(:owner)
      @game = @owner.games.create!(name: "Setupable", number_of_rounds: 2, number_of_teams: 2)
    end

    test "moves the game into team_setup" do
      @game.stub(:players, []) do
        Games::SetupTeams.run!(game: @game)
      end

      assert @game.reload.team_setup?
    end

    test "assigns each player to a team and marks one captain per team" do
      players = [
        Player.new(session_id: "s1", game_id: @game.id),
        Player.new(session_id: "s2", game_id: @game.id),
        Player.new(session_id: "s3", game_id: @game.id)
      ]

      @game.stub(:players, players) do
        Games::SetupTeams.run!(game: @game)
      end

      assert players.all? { |player| player.team_id.present? }
      assert_equal 2, players.count(&:team_captain), "expected one captain per team"
    end

    test "broadcasts a redirect to each joined player's stream pointing at their team" do
      player = Player.new(session_id: "s1", game_id: @game.id)

      streams = @game.stub(:players, [player]) do
        capture_turbo_stream_broadcasts(player.stream_name) do
          Games::SetupTeams.run!(game: @game)
        end
      end

      assert_equal 1, streams.size
      assert_equal "redirect", streams.first["action"]
      assert_equal Rails.application.routes.url_helpers.team_path(player.team), streams.first["target"]
    end

    test "does not broadcast a redirect for a player without an assigned team" do
      player = Player.new(session_id: "s2", game_id: @game.id)

      streams = @game.stub(:players, []) do
        capture_turbo_stream_broadcasts(player.stream_name) do
          @game.broadcast_redirect_players_to_teams
        end
      end

      assert_empty streams
    end

    test "raises when given an invalid input" do
      assert_raises(ActiveInteraction::InvalidInteractionError) do
        Games::SetupTeams.run!(game: nil)
      end
    end
  end
end
