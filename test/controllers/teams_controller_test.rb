require "test_helper"
require "minitest/mock"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)         # game owned by :owner
    @other_team = teams(:two)   # game owned by :other
  end

  test "should show a team" do
    get team_url(@team)
    assert_response :success
  end

  test "shows a team without authentication" do
    get team_url(@other_team)
    assert_response :success
  end

  test "the team captain can rename the team" do
    as_captain_of(@team) do
      patch team_url(@team), params: {team: {name: "Renamed"}}, as: :turbo_stream
    end

    assert_response :success
    assert_equal "Renamed", @team.reload.name
  end

  test "a non-captain cannot rename the team" do
    captain = Player.new(session_id: "s", game_id: @team.game_id, team_captain: false)

    Player.stub(:find_or_create_by!, captain) do
      patch team_url(@team), params: {team: {name: "Renamed"}}, as: :turbo_stream
    end

    assert_response :forbidden
    assert_not_equal "Renamed", @team.reload.name
  end

  private

  # The captain check loads the session's Player from the cache; in tests the
  # cache is the null_store, so stub the lookup to return a captain of `team`.
  def as_captain_of(team)
    captain = Player.new(session_id: "s", game_id: team.game_id, team_id: team.id, team_captain: true)
    Player.stub(:find_or_create_by!, captain) { yield }
  end
end
