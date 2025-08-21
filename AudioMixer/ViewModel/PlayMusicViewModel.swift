//
//  PlayMusicViewModel.swift
//  AudioMixer
//
//  Created by EF2025 on 20/8/25.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

class PlayMusicViewModel: ObservableObject {
    @Published var musicFiles: [MusicFile] = []

//    func fetchMusicFiles() {
//        musicFiles.removeAll()
//        let fileManager = FileManager.default
//        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//        // Find all mp3 files in Documents directory
        let files = (try? fileManager.contentsOfDirectory(at: documents, includingPropertiesForKeys: nil)) ?? []
        for file in files where file.pathExtension.lowercased() == "mp3" {
            let asset = AVURLAsset(url: file)
            let durationSeconds = CMTimeGetSeconds(asset.duration)
            let minutes = Int(durationSeconds) / 60
            let seconds = Int(durationSeconds) % 60
            let durationString = String(format: "%d:%02d", minutes, seconds)
            let displayName = file.deletingPathExtension().lastPathComponent
            musicFiles.append(MusicFile(fileURL: file, displayName: displayName, duration: durationString))
        }
//        // For demo: add a bundled "demo" if present
//        if let demoURL = Bundle.main.url(forResource: "demo", withExtension: "mp3") {
//            let asset = AVURLAsset(url: demoURL)
//            let durationSeconds = CMTimeGetSeconds(asset.duration)
//            let minutes = Int(durationSeconds) / 60
//            let seconds = Int(durationSeconds) % 60
//            let durationString = String(format: "%d:%02d", minutes, seconds)
//            musicFiles.append(MusicFile(fileURL: demoURL, displayName: "Demo", duration: durationString))
//        }
//        // Sort by displayName
//        musicFiles.sort { $0.displayName < $1.displayName }
//    }
}
