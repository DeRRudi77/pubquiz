require "test_helper"

class RoundsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @round = rounds(:one)        # game owned by :owner
    @other_round = rounds(:two)  # game owned by :other
    sign_in @owner
  end

  test "should update a round in an owned game" do
    patch round_url(@round), params: {round: {title: "Updated title"}}, as: :turbo_stream
    assert_response :redirect # only one round -> falls through to game redirect
    assert_equal "Updated title", @round.reload.title
  end

  test "cannot edit a round in a game owned by another user" do
    get edit_round_url(@other_round)
    assert_redirected_to root_path
  end

  test "cannot update a round in a game owned by another user" do
    patch round_url(@other_round), params: {round: {title: "Hijacked"}}, as: :turbo_stream
    assert_response :not_found
    assert_not_equal "Hijacked", @other_round.reload.title
  end

  test "requires authentication" do
    sign_out @owner
    get edit_round_url(@round)
    assert_redirected_to new_user_session_path
  end
end
