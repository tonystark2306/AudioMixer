//
//  AudioFile.swift
//  AudioMixer
//
//  Created by EF2025 on 19/8/25.
//

import Foundation
import UniformTypeIdentifiers

struct AudioFile: Identifiable, Hashable {
    let id: UUID
    let url: URL
    let name: String
    let fileExtension: String
    let mimeType: String // mp3, m4a, wav, ...
    let duration: TimeInterval
    let dateAdded: Date // Thời gian thêm bản ghi
}
