// Entry point for the build script in package.json (bundled by esbuild)
import "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
import "./channels"
import "./controllers"

ActiveStorage.start()
