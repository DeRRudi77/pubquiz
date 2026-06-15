require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @team = teams(:one)         # game owned by :owner
    @other_team = teams(:two)   # game owned by :other
    sign_in @owner
  end

  test "should show a team in an owned game" do
    get team_url(@team)
    assert_response :success
  end

  test "should update a team in an owned game" do
    patch team_url(@team), params: {team: {name: "Renamed"}}, as: :turbo_stream
    assert_response :success
    assert_equal "Renamed", @team.reload.name
  end

  test "cannot view a team in a game owned by another user" do
    get team_url(@other_team)
    assert_redirected_to root_path
  end

  test "cannot update a team in a game owned by another user" do
    patch team_url(@other_team), params: {team: {name: "Hijacked"}}, as: :turbo_stream
    assert_response :not_found
    assert_not_equal "Hijacked", @other_team.reload.name
  end

  test "requires authentication" do
    sign_out @owner
    get team_url(@team)
    assert_redirected_to new_user_session_path
  end
end
