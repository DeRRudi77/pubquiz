module Games
  class UpdatePlayer < ApplicationInteraction
    object :player, class: Player
    string :name

    validates :name, presence: true

    def execute
      player.update(name: name)
      game = player.game.reload
      game.broadcast_replace_to(game)
      player
    end
  end
end
