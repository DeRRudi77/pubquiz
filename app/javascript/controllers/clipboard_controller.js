import { Controller } from "@hotwired/stimulus"

// Copies the source field's value to the clipboard. The value may be a
// relative path (rendered server-side so it stays broadcast-safe); on connect
// we upgrade it to an absolute URL using the current origin.
export default class extends Controller {
  static targets = ["source", "button"];

  connect() {
    this.sourceTarget.value = new URL(this.sourceTarget.value, window.location.origin).href;
  }

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.value).then(() => {
      const original = this.buttonTarget.textContent;
      this.buttonTarget.textContent = "Copied!";
      setTimeout(() => {
        this.buttonTarget.textContent = original;
      }, 1500);
    });
  }
}
