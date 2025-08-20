//
//  MixerViewModel.swift
//  AudioMixer
//
//  Created by iKame Elite Fresher 2025 on 8/20/25.
//

import SwiftUI
import AVFoundation

class MultiTrackAudioMixer {
    private let engine = AVAudioEngine()
    private var players: [AVAudioPlayerNode] = []
    private var files: [AVAudioFile] = []
    var recordingSession = AVAudioSession.sharedInstance()
    
    static func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
    }
    
    func addTrack(url: URL) throws {
        DispatchQueue.global(qos: .background).async {
            do {
                let file = try AVAudioFile(forReading: url)
                let player = AVAudioPlayerNode()
                self.engine.attach(player)
                self.engine.connect(player, to: self.engine.mainMixerNode, format: file.processingFormat)
                self.files.append(file)
                self.players.append(player)
                player.scheduleFile(file, at: nil, completionHandler: nil)
            } catch {
                print("Error loading URL: \(error)")
            }
        }
    }
    
    func playAll() {
        do {
            try engine.start()
            for player in players {
                player.play()
            }
        } catch {
            print("Engine start error: \(error)")
        }
    }
    
    func pause() {
        for player in players { player.pause() }
    }
    
    func stop() {
        for player in players { player.stop() }
        engine.stop()
    }
    
    func exportMixedAudio(to outputURL: URL, completion: @escaping (Bool) -> Void) {
        let mixerNode = engine.mainMixerNode
        let format = mixerNode.outputFormat(forBus: 0)
        guard let outputFile = try? AVAudioFile(forWriting: outputURL, settings: format.settings) else {
            completion(false)
            return
        }
        
        mixerNode.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, _ in
            try? outputFile.write(from: buffer)
        }
        
        do {
            if !engine.isRunning { try engine.start() }
            
            for (i, player) in players.enumerated() {
                player.stop()
                player.scheduleFile(files[i], at: nil, completionHandler: nil)
            }
            
            let leadSeconds = 0.1
            let startHostTime = mach_absolute_time() + AVAudioTime.hostTime(forSeconds: leadSeconds)
            let startTime = AVAudioTime(hostTime: startHostTime)
            for player in players { player.play(at: startTime) }
            
            let durations = files.map { Double($0.length) / $0.processingFormat.sampleRate }
            let maxDuration = durations.max() ?? 0.0
            
            DispatchQueue.global().asyncAfter(deadline: .now() + maxDuration + 0.5) {
                mixerNode.removeTap(onBus: 0)
                self.stop()
                completion(true)
            }
            
        } catch {
            completion(false)
        }
    }
}
