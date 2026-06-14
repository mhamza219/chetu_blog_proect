import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dropdown", "searchQuery", "messages", "body", "currentUser" ]

  connect() {
    this.styleMessages()
    this.scrollToBottom()

    // Watch for new messages appended to container
    if (this.hasMessagesTarget && this.hasBodyTarget) {
      this.observer = new MutationObserver(() => {
        this.styleMessages()
        this.scrollToBottom()
      })
      this.observer.observe(this.messagesTarget, { childList: true })
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  toggleDropdown(e) {
    e.stopPropagation()
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.toggle("d-none")
    }
  }

  closeDropdown(e) {
    if (this.hasDropdownTarget && !this.dropdownTarget.classList.contains("d-none")) {
      if (!this.dropdownTarget.contains(e.target)) {
        this.dropdownTarget.classList.add("d-none")
      }
    }
  }

  filterRooms() {
    if (!this.hasSearchQueryTarget) return
    const query = this.searchQueryTarget.value.trim().toLowerCase()
    
    const links = this.element.querySelectorAll(".room-item-link")
    links.forEach(link => {
      const item = link.querySelector(".wa-room-item")
      if (!item) return
      const name = item.dataset.roomName || ""
      
      if (name.includes(query)) {
        link.style.display = ""
      } else {
        link.style.display = "none"
      }
    })
  }

  styleMessages() {
    if (!this.hasCurrentUserTarget) return
    const currentUserId = this.currentUserTarget.dataset.id

    const messages = this.element.querySelectorAll(".msg-container")
    messages.forEach(msg => {
      const senderId = msg.dataset.senderId
      const bubble = msg.querySelector(".msg-bubble")
      if (!bubble) return

      if (senderId === currentUserId) {
        msg.classList.remove("justify-content-start")
        msg.classList.add("justify-content-end")
        bubble.classList.remove("msg-bubble-incoming")
        bubble.classList.add("msg-bubble-outgoing")

        const senderName = bubble.querySelector(".msg-sender-name")
        if (senderName) senderName.style.display = "none"

        const ticks = msg.querySelector(".msg-status-ticks")
        if (ticks) ticks.classList.remove("d-none")
      } else {
        msg.classList.remove("justify-content-end")
        msg.classList.add("justify-content-start")
        bubble.classList.remove("msg-bubble-outgoing")
        bubble.classList.add("msg-bubble-incoming")

        const ticks = msg.querySelector(".msg-status-ticks")
        if (ticks) ticks.classList.add("d-none")

        if (msg.dataset.read === "false") {
          this.markMessageAsRead(msg)
        }
      }
    })
  }

  markMessageAsRead(msgElement) {
    const roomId = this.element.querySelector(".wa-chat-main")?.dataset.roomId
    const messageId = msgElement.dataset.messageId
    if (!roomId || !messageId) return

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ""

    msgElement.dataset.read = "true"

    fetch(`/rooms/${roomId}/messages/${messageId}/read`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      }
    }).then(response => {
      if (!response.ok) {
        msgElement.dataset.read = "false"
      }
    }).catch(() => {
      msgElement.dataset.read = "false"
    })
  }

  scrollToBottom() {
    if (this.hasBodyTarget) {
      this.bodyTarget.scrollTop = this.bodyTarget.scrollHeight
    }
  }
}
