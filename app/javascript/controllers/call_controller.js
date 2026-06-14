import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = [ "overlay", "incomingCallBox", "localVideo", "remoteVideo", "status", "callerName", "audioBtn", "videoBtn" ]
  static values = { userId: Number }

  connect() {
    this.localStream = null
    this.peerConnection = null
    this.remoteUserId = null
    this.isMutedAudio = false
    this.isMutedVideo = false
    this.isSimulated = false

    // Subscribe to signaling channel
    this.channel = consumer.subscriptions.create("CallChannel", {
      received: (data) => this.handleSignal(data)
    })
  }

  disconnect() {
    this.cleanupCall()
    if (this.channel) {
      this.channel.unsubscribe()
    }
  }

  // Action: Triggered by clicking call button in chat header
  startCall(e) {
    e.preventDefault()
    this.remoteUserId = parseInt(e.currentTarget.dataset.targetUserId)
    this.callType = e.currentTarget.dataset.callType // 'audio' or 'video'

    this.showOverlay()
    this.incomingCallBoxTarget.classList.add("d-none")
    this.statusTarget.textContent = "Calling..."
    this.callerNameTarget.textContent = e.currentTarget.dataset.targetUserName

    this.setupLocalMedia().then(() => {
      this.initPeerConnection()
      
      // Create offer
      this.peerConnection.createOffer()
        .then(offer => this.peerConnection.setLocalDescription(offer))
        .then(() => {
          this.sendSignal("offer", {
            sdp: this.peerConnection.localDescription,
            callType: this.callType
          })
        })
    }).catch(err => {
      console.warn("Media capture failed, entering simulated loopback call:", err)
      this.startSimulatedCall()
    })
  }

  // Receive signal from CallChannel
  handleSignal(data) {
    const { from, from_name, type, payload } = data

    switch (type) {
      case "offer":
        if (this.peerConnection) return // busy
        this.remoteUserId = from
        this.callType = payload.callType
        this.showOverlay()
        this.incomingCallBoxTarget.classList.remove("d-none")
        this.statusTarget.textContent = "Incoming Call..."
        this.callerNameTarget.textContent = from_name
        this.pendingOffer = payload.sdp
        break

      case "answer":
        if (this.isSimulated) {
          this.statusTarget.textContent = "Connected (Simulated)"
          return
        }
        if (this.peerConnection) {
          this.peerConnection.setRemoteDescription(new RTCSessionDescription(payload))
          this.statusTarget.textContent = "Connected"
        }
        break

      case "candidate":
        if (this.isSimulated) return
        if (this.peerConnection) {
          this.peerConnection.addIceCandidate(new RTCIceCandidate(payload))
        }
        break

      case "decline":
        this.statusTarget.textContent = "Call Declined/Busy"
        setTimeout(() => this.cleanupCall(), 2500)
        break

      case "hangup":
        this.statusTarget.textContent = "Call Ended"
        setTimeout(() => this.cleanupCall(), 1500)
        break
    }
  }

  acceptCall() {
    this.incomingCallBoxTarget.classList.add("d-none")
    this.statusTarget.textContent = "Connecting..."

    this.setupLocalMedia().then(() => {
      this.initPeerConnection()
      
      this.peerConnection.setRemoteDescription(new RTCSessionDescription(this.pendingOffer))
        .then(() => this.peerConnection.createAnswer())
        .then(answer => this.peerConnection.setLocalDescription(answer))
        .then(() => {
          this.sendSignal("answer", this.peerConnection.localDescription)
          this.statusTarget.textContent = "Connected"
        })
    }).catch(err => {
      console.warn("Media capture failed on accept, entering simulated call:", err)
      this.startSimulatedCall(true)
    })
  }

  declineCall() {
    this.sendSignal("decline", {})
    this.cleanupCall()
  }

  hangup() {
    this.sendSignal("hangup", {})
    this.cleanupCall()
  }

  // WebRTC Setup Helpers
  setupLocalMedia() {
    if (!window.isSecureContext || !navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      this.statusTarget.textContent = "Security Blocked: Use Localhost/HTTPS"
      alert("Browser Security Block: Camera and microphone access is restricted to secure origins (HTTPS or localhost).\n\nPlease open the app via 'http://localhost:3000/' (or 'http://127.0.0.1:3000/') instead of using a local network IP address, or configure SSL/HTTPS.")
      throw new Error("Insecure Context: MediaDevices restricted")
    }

    const constraints = {
      audio: true,
      video: this.callType === 'video'
    }

    return navigator.mediaDevices.getUserMedia(constraints)
      .catch(err => {
        if (constraints.video) {
          console.warn("Camera check failed, falling back to audio-only stream:", err)
          this.callType = 'audio'
          return navigator.mediaDevices.getUserMedia({ audio: true })
        }
        throw err
      })
      .then(stream => {
        this.localStream = stream
        if (this.hasLocalVideoTarget) {
          if (this.callType === 'video') {
            this.localVideoTarget.srcObject = stream
            this.localVideoTarget.classList.remove("d-none")
            this.localVideoTarget.play().catch(e => console.warn("Local play failed:", e))
          } else {
            this.localVideoTarget.classList.add("d-none")
          }
        }
      })
  }

  initPeerConnection() {
    this.peerConnection = new RTCPeerConnection({
      iceServers: [{ urls: 'stun:stun.l.google.com:19302' }]
    })

    // Add local tracks
    if (this.localStream) {
      this.localStream.getTracks().forEach(track => {
        this.peerConnection.addTrack(track, this.localStream)
      })
    }

    // ICE candidates
    this.peerConnection.onicecandidate = (e) => {
      if (e.candidate) {
        this.sendSignal("candidate", e.candidate)
      }
    }

    // Remote stream
    this.peerConnection.ontrack = (e) => {
      if (this.hasRemoteVideoTarget) {
        this.remoteVideoTarget.srcObject = e.streams[0]
        this.remoteVideoTarget.classList.remove("d-none")
        this.remoteVideoTarget.play().catch(e => console.warn("Remote play failed:", e))
      }
    }
  }

  sendSignal(type, payload) {
    if (this.channel && this.remoteUserId) {
      this.channel.perform("send_signal", {
        to: this.remoteUserId,
        type: type,
        payload: payload
      })
    }
  }

  // Mock Simulated Call Fallback
  startSimulatedCall(isReceiver = false) {
    this.isSimulated = true
    this.statusTarget.textContent = isReceiver ? "Connected (Simulated)" : "Ringing..."
    
    // Simulate connection for caller after 3 seconds
    if (!isReceiver) {
      setTimeout(() => {
        if (this.isSimulated) {
          this.statusTarget.textContent = "Connected (Simulated)"
          this.sendSignal("answer", {})
        }
      }, 3000)
    }

    // Play a mock canvas visualizer on local video/remote video targets to indicate live feeds
    this.drawSimulatedFeed(this.localVideoTarget, "Local User Feed")
    this.drawSimulatedFeed(this.remoteVideoTarget, "Remote User Feed")
  }

  drawSimulatedFeed(videoElement, text) {
    if (!videoElement) return
    videoElement.classList.add("d-none") // Hide actual video element

    // Find or create canvas overlay
    let canvasId = videoElement.id + "-canvas"
    let canvas = document.getElementById(canvasId)
    if (!canvas) {
      canvas = document.createElement("canvas")
      canvas.id = canvasId
      canvas.width = 320
      canvas.height = 240
      canvas.style.width = "100%"
      canvas.style.height = "100%"
      canvas.style.borderRadius = "8px"
      canvas.style.objectFit = "cover"
      videoElement.parentNode.appendChild(canvas)
    }

    const ctx = canvas.getContext("2d")
    let hue = Math.random() * 360
    
    const animate = () => {
      if (!this.isSimulated) {
        canvas.remove()
        return
      }
      ctx.fillStyle = `hsl(${hue}, 40%, 20%)`
      ctx.fillRect(0, 0, canvas.width, canvas.height)

      // Draw pulse circles
      ctx.strokeStyle = `hsl(${(hue + 120) % 360}, 60%, 50%)`
      ctx.lineWidth = 3
      ctx.beginPath()
      ctx.arc(canvas.width / 2, canvas.height / 2, 40 + Math.sin(Date.now() / 200) * 15, 0, Math.PI * 2)
      ctx.stroke()

      // Draw status label
      ctx.fillStyle = "#ffffff"
      ctx.font = "14px Outfit, sans-serif"
      ctx.textAlign = "center"
      ctx.fillText(text, canvas.width / 2, canvas.height / 2 + 75)

      hue = (hue + 0.5) % 360
      this.simulationFrame = requestAnimationFrame(animate)
    }
    animate()
  }

  // Actions: Controls
  toggleMuteAudio() {
    this.isMutedAudio = !this.isMutedAudio
    if (this.localStream) {
      this.localStream.getAudioTracks().forEach(track => track.enabled = !this.isMutedAudio)
    }
    this.audioBtnTarget.classList.toggle("btn-control-active", !this.isMutedAudio)
    this.audioBtnTarget.classList.toggle("btn-control-muted", this.isMutedAudio)
  }

  toggleMuteVideo() {
    this.isMutedVideo = !this.isMutedVideo
    if (this.localStream) {
      this.localStream.getVideoTracks().forEach(track => track.enabled = !this.isMutedVideo)
    }
    this.videoBtnTarget.classList.toggle("btn-control-active", !this.isMutedVideo)
    this.videoBtnTarget.classList.toggle("btn-control-muted", this.isMutedVideo)
  }

  showOverlay() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("d-none")
      this.overlayTarget.style.display = "flex"
    }
  }

  cleanupCall() {
    if (this.localStream) {
      this.localStream.getTracks().forEach(track => track.stop())
      this.localStream = null
    }
    if (this.peerConnection) {
      this.peerConnection.close()
      this.peerConnection = null
    }
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("d-none")
      this.overlayTarget.style.display = "none"
    }
    if (this.hasLocalVideoTarget) {
      this.localVideoTarget.srcObject = null
    }
    if (this.hasRemoteVideoTarget) {
      this.remoteVideoTarget.srcObject = null
    }
    this.remoteUserId = null
    this.isSimulated = false
    if (this.simulationFrame) {
      cancelAnimationFrame(this.simulationFrame)
    }
  }
}
