module RoundsHelper
  def round_form_turbo_frame(round)
    round.number == round.game.number_of_rounds ? '_top' : ''
  end
end
