require "test_helper"

module Rounds
  class AddQuestionTest < ActiveSupport::TestCase
    setup { @round = rounds(:one) } # has one fixture question, number 1

    test "adds a question numbered max + 1" do
      assert_difference -> { @round.questions.count }, 1 do
        Rounds::AddQuestion.run!(round: @round)
      end
      assert_equal 2, @round.questions.maximum(:number)
    end

    test "numbers the first question 1 on an empty round" do
      @round.questions.destroy_all

      Rounds::AddQuestion.run!(round: @round)

      assert_equal [1], @round.questions.pluck(:number)
    end

    test "raises when given an invalid input" do
      assert_raises(ActiveInteraction::InvalidInteractionError) do
        Rounds::AddQuestion.run!(round: nil)
      end
    end
  end
end
