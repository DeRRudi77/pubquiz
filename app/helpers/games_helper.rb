module GamesHelper
  def game_state_class(state)
    case state
    when 'pending_start'
      'is-info is-light'
    when 'started'
      'is-danger is-light'
    when 'pending_results'
      'is-warning is-light'
    when 'finished'
      'is-success is-light'
    end
  end
end
