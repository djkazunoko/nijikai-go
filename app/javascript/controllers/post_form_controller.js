import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="post-form"
export default class extends Controller {
  static targets = ["content", "submit"];

  connect() {
    this.toggleSubmitButton();
  }

  toggleSubmitButton() {
    const isEmpty = this.contentTarget.value.trim() === "";
    this.submitTarget.disabled = isEmpty;
  }

  onInput() {
    this.toggleSubmitButton();
  }
}
