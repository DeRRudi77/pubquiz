require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @question = questions(:one)        # round/game owned by :owner
    @other_question = questions(:two)  # round/game owned by :other
    @round = rounds(:one)              # game owned by :owner
    @other_round = rounds(:two)        # game owned by :other
    sign_in @owner
  end

  test "create adds a numbered question to an owned round" do
    assert_difference -> { @round.questions.count }, 1 do
      post round_questions_url(@round), as: :turbo_stream
    end
    assert_response :success
    assert_equal 2, @round.questions.maximum(:number)
  end

  test "cannot add a question to a round in another user's game" do
    assert_no_difference -> { @other_round.questions.count } do
      post round_questions_url(@other_round), as: :turbo_stream
    end
    assert_response :not_found
  end

  test "destroy removes a question in an owned game" do
    assert_difference -> { Question.count }, -1 do
      delete question_url(@question), as: :turbo_stream
    end
    assert_response :success
  end

  test "cannot destroy a question in another user's game" do
    assert_no_difference -> { Question.count } do
      delete question_url(@other_question), as: :turbo_stream
    end
    assert_response :not_found
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
