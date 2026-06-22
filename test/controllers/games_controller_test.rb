require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @game = games(:one)        # owned by :owner
    @other_game = games(:two)  # owned by :other
    sign_in @owner
  end

  # Regression: the wizard's add/remove-question controls must be turbo-method
  # links, never button_to (a nested <form> breaks Turbo and leaks raw HTML).
  test "wizard step 2 renders add/remove question as turbo-method links" do
    get edit_game_url(@game, step: 2)
    assert_response :success
    assert_select "a[data-turbo-method='post']", text: "Add question"
    assert_select "a[data-turbo-method='delete']", text: "Remove question"
    assert_select "input[value='Add question']", false
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

  # Regression: lifecycle actions must replace the game frame that the show
  # page actually renders (dom_id(@game)), not the wizard-only "game_wizard"
  # frame — otherwise the host page never updates in place and needs a reload.
  test "setup_teams replaces the game frame and moves the game to team_setup" do
    patch setup_teams_game_url(@game), as: :turbo_stream
    assert_response :success
    assert @game.reload.team_setup?
    assert_select "turbo-stream[action='replace'][target=?]", ActionView::RecordIdentifier.dom_id(@game)
  end

  test "start replaces the game frame and starts the game" do
    @game.team_setup!
    patch start_game_url(@game), as: :turbo_stream
    assert_response :success
    assert @game.reload.started?
    assert_select "turbo-stream[action='replace'][target=?]", ActionView::RecordIdentifier.dom_id(@game)
  end

  test "requires authentication" do
    sign_out @owner
    get games_url
    assert_redirected_to new_user_session_path
  end
end
