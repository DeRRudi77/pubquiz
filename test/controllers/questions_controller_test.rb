require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @question = questions(:one)        # round/game owned by :owner
    @other_question = questions(:two)  # round/game owned by :other
    sign_in @owner
  end

  # NOTE: index/show/new/edit have no templates (scaffold leftovers); only the
  # mutating actions are exercised, plus the ownership guard on a GET.

  test "index is scoped to the current user's games" do
    scoped = Question.joins(round: :game).where(games: {user_id: @owner.id})
    assert_includes scoped, @question
    assert_not_includes scoped, @other_question
  end

  test "should update a question in an owned game" do
    patch question_url(@question), params: {question: {question: "New text?"}}
    assert_redirected_to question_url(@question)
    assert_equal "New text?", @question.reload.question
  end

  test "cannot view a question in a game owned by another user" do
    get question_url(@other_question)
    assert_redirected_to root_path
  end

  test "cannot update a question in a game owned by another user" do
    patch question_url(@other_question), params: {question: {question: "Hijacked"}}
    assert_response :not_found
    assert_not_equal "Hijacked", @other_question.reload.question
  end

  test "requires authentication" do
    sign_out @owner
    patch question_url(@question), params: {question: {question: "x"}}
    assert_redirected_to new_user_session_path
  end
end
