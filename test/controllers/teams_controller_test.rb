require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)         # game owned by :owner
    @other_team = teams(:two)   # game owned by :other
  end

  test "should show a team" do
    get team_url(@team)
    assert_response :success
  end

  test "should update a team" do
    patch team_url(@team), params: {team: {name: "Renamed"}}, as: :turbo_stream
    assert_response :success
    assert_equal "Renamed", @team.reload.name
  end

  test "shows a team without authentication" do
    get team_url(@other_team)
    assert_response :success
  end

  test "updates a team without authentication" do
    patch team_url(@other_team), params: {team: {name: "Renamed"}}, as: :turbo_stream
    assert_response :success
    assert_equal "Renamed", @other_team.reload.name
  end
end
