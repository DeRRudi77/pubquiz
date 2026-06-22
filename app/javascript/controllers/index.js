import { Application } from "@hotwired/stimulus"
import AnswerController from "./answer_controller"
import ClipboardController from "./clipboard_controller"

const application = Application.start()
application.register("answer", AnswerController)
application.register("clipboard", ClipboardController)

export { application }
