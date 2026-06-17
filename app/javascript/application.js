// Entry point for the build script in package.json (bundled by esbuild)
import "@hotwired/turbo-rails"
import { Turbo } from "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
import "./channels"
import "./controllers"

// Custom Turbo Stream action: client-side redirect.
// Broadcast from Game#broadcast_redirect_players_to_teams to send joined
// players to their assigned team page when the host starts the game.
Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.getAttribute("target"))
}

ActiveStorage.start()
