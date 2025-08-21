//
//  AudioFileDocument.swift
//  AudioMixer
//
//  Created by EF2025 on 21/8/25.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI

// Restore the custom UTType extension!
struct AudioFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.m4a] }
    static var writableContentTypes: [UTType] { [.m4a] }
    var url: URL

    init(url: URL) {
        self.url = url
    }
    init(configuration: ReadConfiguration) throws {
        guard let fileURL = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".m4a")
        try fileURL.write(to: tempURL)
        self.url = tempURL
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: url)
    }
}
