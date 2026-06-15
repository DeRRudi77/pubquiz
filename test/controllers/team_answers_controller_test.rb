require "test_helper"

class TeamAnswersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @answer = team_answers(:one)        # game owned by :owner
    @other_answer = team_answers(:two)  # game owned by :other
    sign_in @owner
  end

  test "should score an answer in an owned game" do
    patch team_answer_url(@answer), params: {team_answer: {points: 5}}, as: :turbo_stream
    assert_response :success
    assert_equal 5, @answer.reload.points
  end

  test "cannot score an answer in a game owned by another user" do
    patch team_answer_url(@other_answer), params: {team_answer: {points: 99}}, as: :turbo_stream
    assert_response :not_found
    assert_nil @other_answer.reload.points
  end

  test "requires authentication" do
    sign_out @owner
    patch team_answer_url(@answer), params: {team_answer: {points: 5}}, as: :turbo_stream
    assert_redirected_to new_user_session_path
  end
end
