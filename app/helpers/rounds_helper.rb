module RoundsHelper
  def round_form_turbo_frame(round)
    round.number == round.game.number_of_rounds ? "_top" : ""
  end

  def current_viewing_round(game)
    round_param.present? ? game.rounds.find(round_param[:round_id]) : game.current_round
  end

  def rounds_tab_class(game, round)
    current_viewing_round(game).id == round.id ? "is-active" : ""
  end

  def round_param
    params.permit(:round_id)
  end
end
