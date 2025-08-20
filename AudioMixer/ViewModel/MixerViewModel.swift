//
//  MixerViewModel.swift
//  AudioMixer
//
//  Created by iKame Elite Fresher 2025 on 8/20/25.
//

import SwiftUI
import AVFoundation
import Combine

class MixerViewModel: ObservableObject {
    private let engine = AVAudioEngine()
    private var players: [AVAudioPlayerNode] = []
    private var files: [AVAudioFile] = []
    var recordingSession = AVAudioSession.sharedInstance()
    
    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
    }
    
    init() {
        do {
            try configureAudioSession()
        } catch {
            print("Failed to create audio session: \(error)")
        }
    }
    
    func loadTrack(addedAudios: [AddedAudio]) -> Bool {
        for audio in addedAudios {
            do {
                let file = try AVAudioFile(forReading: audio.fileURL)
                let player = AVAudioPlayerNode()
                engine.attach(player)
                engine.connect(player, to: engine.mainMixerNode, format: file.processingFormat)
                files.append(file)
                players.append(player)
                player.scheduleFile(file, at: nil, completionHandler: nil)
            } catch {
                print("Error loading URL: \(error)")
                return false
            }
        }
        return true
    }
    
    func playAll()  {
        if !engine.isRunning {
            try? engine.start()
        }
        for player in players {
            player.play()
        }
    }
    
    func pause() { players.forEach { $0.pause() } }
    
    func stop() {
        players.forEach { $0.stop() }
        if engine.isRunning {
            engine.stop()
        }
    }
    
//    func exportMixedAudio(to outputURL: URL, completion: @escaping (Bool) -> Void) {
//        let mixerNode = engine.mainMixerNode
//        let format = mixerNode.outputFormat(forBus: 0)
//
//        guard let outputFile = try? AVAudioFile(forWriting: outputURL, settings: format.settings) else {
//            completion(false)
//            return
//        }
//
//        mixerNode.removeTap(onBus: 0)
//
//        mixerNode.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, _ in
//            do {
//                try outputFile.write(from: buffer)
//            } catch {
//                print("Write error: \(error)")
//            }
//        }
//
//        do {
//            if !engine.isRunning {
//                try engine.start()
//            }
//
//            for player in players {
//                player.play()
//            }
//
//            let duration = files.map { Double($0.length) / $0.processingFormat.sampleRate }.max() ?? 0
//
//            DispatchQueue.global().asyncAfter(deadline: .now() + duration + 0.5) {
//                self.engine.stop()
//                mixerNode.removeTap(onBus: 0)
//                completion(true)
//            }
//        } catch {
//            print("Engine error: \(error)")
//            completion(false)
//        }
//    }

}
