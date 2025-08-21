import Foundation
import AVFoundation
import Combine

class MixingViewModel: ObservableObject {
    @Published var isPlaying = false
    private var audioEngine = AVAudioEngine()
    private var playerNodes: [AVAudioPlayerNode] = []
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("setup failed: \(error)")
        }
    }
    
    func mixAudio(audioFiles: [URL]) {
        guard !audioFiles.isEmpty else { return }
        resetMixAudio()
        
        do {
            let mixer = AVAudioMixerNode()
            audioEngine.attach(mixer)
            audioEngine.connect(mixer, to: audioEngine.outputNode, format: nil)
            playerNodes.removeAll()
            for fileURL in audioFiles {
                let playerNode = AVAudioPlayerNode()
                let audioFile = try AVAudioFile(forReading: fileURL)
                
                audioEngine.attach(playerNode)
                audioEngine.connect(playerNode, to: mixer, format: audioFile.processingFormat)
                
                playerNodes.append(playerNode)
            }
            
            try audioEngine.start()
            
            for (index, fileURL) in audioFiles.enumerated() {
                let playerNode = playerNodes[index]
                let audioFile = try AVAudioFile(forReading: fileURL)
                playerNode.scheduleFile(audioFile, at: nil)
                playerNode.play()
            }
            
            DispatchQueue.main.async {
                self.isPlaying = true
            }
            
        } catch {
            print("failed: \(error)")
        }
    }
    
    private func resetMixAudio() {
        audioEngine.stop()
        for playerNode in playerNodes {
            playerNode.stop()
        }
        audioEngine = AVAudioEngine()
        playerNodes.removeAll()
        isPlaying = false
    }
    
    func stopAudio() {
        playerNodes.forEach { $0.stop() }
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}
