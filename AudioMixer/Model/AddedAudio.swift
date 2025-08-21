//
//  SourceType.swift
//  AudioMixer
//
//  Created by Ngoc Ha on 20/8/25.
//

import Foundation

enum SourceType: Identifiable {
    case record, playMusic
    var id: Int { self.hashValue }
}

struct AddedAudio: Identifiable, Equatable {
    let id = UUID()
    let fileURL: URL
    let displayName: String
    let source: SourceType
}
