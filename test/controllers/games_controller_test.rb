require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @game = games(:one)        # owned by :owner
    @other_game = games(:two)  # owned by :other
    sign_in @owner
  end

  test "index lists only the current user's games" do
    get games_url
    assert_response :success
    assert_includes @owner.games, @game
    assert_not_includes @owner.games, @other_game
  end

  test "should get new" do
    get new_game_url
    assert_response :success
  end

  test "create assigns the game to the current user" do
    assert_difference("Game.count") do
      post games_url, params: {game: {name: "Fresh", number_of_rounds: 1, number_of_teams: 1}}
    end
    created = Game.find_by!(name: "Fresh") # UUID PKs aren't creation-ordered, so don't use .last
    assert_equal @owner, created.user
    assert_redirected_to edit_game_path(created, step: 2)
  end

  test "should show own game" do
    get game_url(@game)
    assert_response :success
  end

  test "should update own game" do
    patch game_url(@game), params: {game: {name: "Renamed"}}
    assert_redirected_to game_url(@game)
  end

  test "should destroy own game" do
    assert_difference("Game.count", -1) do
      delete game_url(@game)
    end
    assert_redirected_to games_url
  end

  test "cannot show a game owned by another user" do
    get game_url(@other_game)
    assert_redirected_to root_path
  end

  test "cannot destroy a game owned by another user" do
    assert_no_difference("Game.count") do
      delete game_url(@other_game)
    end
    assert_response :not_found
  end

  test "requires authentication" do
    sign_out @owner
    get games_url
    assert_redirected_to new_user_session_path
  end
end
