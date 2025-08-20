//
//  Recording.swift
//  AudioMixer
//
//  Created by Ngoc Ha on 20/8/25.
//

import Foundation


struct Recording: Identifiable {
    let id = UUID()
    let fileURL: URL
    let createdAt: Date
}
