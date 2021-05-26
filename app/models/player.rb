class Player
  include ActiveModel::Model

  attr_accessor :session_id, :name, :game_id, :team_id, :team_captain

  def save!
    Rails.cache.write(
      Player.cache_key(session_id, game_id),
      {
        session_id: session_id,
        name: name,
        game_id: game_id,
        team_id: team_id,
        team_captian: team_captain
      },
      expires_in: 24.hours,
      )
  end

  class << self
    def find(session_id, game_id)
      cache = Rails.cache.read(cache_key(session_id, game_id))
      new(session_id: session_id,name: cache[:name], game_id: cache[:game_id], team_id: cache[:team_id], )
    end

    def cache_key(session_id, game_id)
      "PLAYER:#{game_id}:#{session_id}"
    end
  end
end
