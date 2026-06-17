class Player
  include ActiveModel::Model

  attr_accessor :session_id, :name, :game_id, :team_id, :team_captain

  def save!
    Rails.cache.write(
      cache_key,
      {
        session_id: session_id,
        name: name,
        game_id: game_id,
        team_id: team_id,
        team_captain: !!team_captain
      },
      expires_in: 24.hours
    )
  end

  def update(attributes)
    assign_attributes(attributes)
    save!
    true
  end

  def cache_key
    self.class.cache_key(session_id, game_id)
  end

  # Per-player Turbo Stream name. Used by the join page subscription and by
  # Game#broadcast_redirect_players_to_teams so the two can't drift.
  def stream_name
    "game_#{game_id}_player_#{session_id}"
  end

  def game
    @game ||= Game.find(game_id)
  end

  def team
    @team ||= Team.find(team_id) if team_id
  end

  class << self
    def find_or_create_by!(session_id:, game_id:)
      cache = Rails.cache.read(cache_key(session_id, game_id))
      if cache
        new(session_id: session_id, name: cache[:name], game_id: cache[:game_id], team_id: cache[:team_id], team_captain: cache[:team_captain])
      else
        player = new(session_id: session_id, game_id: game_id)
        player.save!
        player
      end
    end

    def find(session_id:, game_id:)
      find_by_key(cache_key(session_id, game_id))
    end

    def find_by_key(key)
      cache = Rails.cache.read(key)
      new(session_id: cache[:session_id], name: cache[:name], game_id: cache[:game_id], team_id: cache[:team_id], team_captain: cache[:team_captain])
    end

    def find_all_by_game_id(game_id)
      # Players live in the Redis cache; stores without a Redis client
      # (e.g. the null_store used in tests) hold no players.
      return [] unless Rails.cache.respond_to?(:redis)

      keys = []
      cursor = "0"
      Rails.cache.redis.with do |redis_client|
        loop do
          cursor, batch = redis_client.scan(cursor, match: "PLAYER:#{game_id}:*", count: 100)
          keys.concat(batch)
          break if cursor == "0"
        end
      end

      Rails.logger.debug(keys)

      keys.map { |key| find_by_key(key) }
    end

    def cache_key(session_id, game_id)
      "PLAYER:#{game_id}:#{session_id}"
    end
  end
end
