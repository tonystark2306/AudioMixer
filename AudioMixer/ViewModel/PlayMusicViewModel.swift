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

    func fetchMusicFiles() {
        musicFiles.removeAll()
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let seenFiles: Set<String> = []
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
        for (fileName, displayName, durationString) in bundledSongs {
            if seenFiles.contains(fileName.lowercased()) { continue } 
            if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
                musicFiles.append(MusicFile(fileURL: url, displayName: displayName, duration: durationString))
            }
        }
        musicFiles.sort { $0.displayName < $1.displayName }
    }
}
