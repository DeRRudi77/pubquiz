import { Application } from "@hotwired/stimulus"
import AnswerController from "./answer_controller"

const application = Application.start()
application.register("answer", AnswerController)

export { application }
