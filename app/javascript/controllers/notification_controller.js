import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "progress" ]
  static values = {
    duration: { type: Number, default: 180000 } // 3 minutes in milliseconds
  }

  connect() {
    this.startTime = Date.now()
    this.animateProgress()
  }

  disconnect() {
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame)
    }
  }

  animateProgress() {
    const elapsed = Date.now() - this.startTime
    const remaining = Math.max(0, this.durationValue - elapsed)
    const percentage = (remaining / this.durationValue) * 100

    if (this.hasProgressTarget) {
      this.progressTarget.style.width = `${percentage}%`
    }

    if (remaining <= 0) {
      this.close()
    } else {
      this.animationFrame = requestAnimationFrame(() => this.animateProgress())
    }
  }

  close() {
    // Fade out and remove element
    this.element.style.transition = "opacity 0.4s ease, transform 0.4s ease"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(-10px)"

    setTimeout(() => {
      this.element.remove()
    }, 400)
  }
}
