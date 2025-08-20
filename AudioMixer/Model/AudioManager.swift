import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentSong = ""
    
    private var timer: Timer?
    
    private init() {
        setupAudioSession()
        setupAudioEngine()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
        
        do {
            try audioEngine.start()
        } catch {
            print("Failed: \(error)")
        }
    }
    
    func loadAndPlay(songName: String) {
        guard let url = Bundle.main.url(forResource: songName, withExtension: "mp3") else {
            print("Not found: \(songName).mp3")
            return
        }
        
        do {
            if !audioEngine.isRunning {
                try audioEngine.start()
            }
            
            audioFile = try AVAudioFile(forReading: url)
            guard let audioFile = audioFile else {
                print("Failed")
                return
            }
            
            let format = audioFile.processingFormat
            audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
            
            currentSong = songName
            duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate
            currentTime = 0
            
            playerNode.stop()
            playerNode.scheduleFile(audioFile, at: nil) {
                DispatchQueue.main.async {
                    if self.currentTime >= self.duration - 0.1 {
                        self.isPlaying = false
                        self.currentTime = 0
                        self.stopTimer()
                    }
                }
            }
            playerNode.play()
            isPlaying = true
            
            startTimer()
            print("Playing: \(songName), Duration: \(duration)")
        } catch {
            print("Error loading audio file: \(error)")
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            playerNode.pause()
            isPlaying = false
            stopTimer()
        } else {
            if !audioEngine.isRunning {
                do {
                    try audioEngine.start()
                } catch {
                    print("Failed to restart audio engine: \(error)")
                    return
                }
            }
            playerNode.play()
            isPlaying = true
            startTimer()
        }
    }
    
    func seek(to time: TimeInterval) {
        guard let audioFile = audioFile else { return }
        
        let sampleRate = audioFile.fileFormat.sampleRate
        let startFrame = AVAudioFramePosition(time * sampleRate)
        let frameCount = AVAudioFrameCount(audioFile.length - startFrame)
        
        playerNode.stop()
        
        if frameCount > 0 && startFrame < audioFile.length {
            do {
                if !audioEngine.isRunning {
                    try audioEngine.start()
                }
                playerNode.scheduleSegment(audioFile, startingFrame: startFrame, frameCount: frameCount, at: nil)
                if isPlaying {
                    playerNode.play()
                }
                currentTime = time
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func skipForward() {
        let newTime = min(currentTime + 15, duration)
        seek(to: newTime)
    }
    
    func skipBackward() {
        let newTime = max(currentTime - 15, 0)
        seek(to: newTime)
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.isPlaying && self.playerNode.isPlaying {
                self.currentTime += 0.1
                if self.currentTime >= self.duration {
                    self.currentTime = self.duration
                    self.isPlaying = false
                    self.stopTimer()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
