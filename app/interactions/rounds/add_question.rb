module Rounds
  class AddQuestion < ApplicationInteraction
    object :round

    def execute
      round.questions.create!(number: (round.questions.maximum(:number) || 0) + 1)
      round
    end
  end
end
