module Rounds
  class QuestionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_round, only: %i[create]
    before_action :set_question, only: %i[destroy]

    # POST /rounds/:round_id/questions
    def create
      Rounds::AddQuestion.run!(round: @round)
      render turbo_stream: turbo_stream.replace(@round, partial: "rounds/form", locals: {round: @round.reload})
    end

    # DELETE /questions/:id
    def destroy
      round = @question.round
      @question.destroy
      render turbo_stream: turbo_stream.replace(round, partial: "rounds/form", locals: {round: round.reload})
    end

    private

    def set_round
      @round = Round.find(params[:round_id])
      require_game_owner!(@round.game)
    end

    def set_question
      @question = Question.find(params[:id])
      require_game_owner!(@question.round.game)
    end
  end
end
