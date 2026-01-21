import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="greet"
export default class extends Controller {
  connect() {
    // this.element.textContent = "Greet Hii"
  }

  Hii(){
    this.element.textContent = "Greet Hii"

  }
}
