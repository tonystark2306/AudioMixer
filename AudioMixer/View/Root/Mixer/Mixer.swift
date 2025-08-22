import SwiftUI
import Foundation
import AVFoundation
import UniformTypeIdentifiers

extension UTType {
    static var m4a: UTType {
        UTType(filenameExtension: "m4a")
        ?? UTType(importedAs: "com.apple.m4a-audio")
    }
}

struct Mixer: View {
    @State private var isAddingTwoTrack: Bool = false
    @State private var currentNumberAudio: Int = 0
    @State private var showSelectSourceSheet: Bool = false
    @State private var selectedSource: SourceType? = nil
    @State private var addedAudios: [AddedAudio] = []
    @StateObject private var mixingViewModel = MixingViewModel()

    @State private var mixedFileURL: URL? = nil
    @State private var isExporting: Bool = false
    @State private var exportError: Error? = nil
    @State private var player: AVAudioPlayer?
    
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
    
    var body: some View {
        VStack {
            HStack {
                Text("Audio Mixer")
                    .font(Font.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    showSelectSourceSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .tint(Color(.systemGray4))
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            if !addedAudios.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(addedAudios) { audio in
                        HStack {
                            Image(systemName: audio.source == .record ? "waveform" : "music.note")
                                .foregroundColor(.accentColor)
                            Text(audio.displayName)
                                .lineLimit(1)
                            Spacer()
                            Button(action: {
                                if let idx = addedAudios.firstIndex(of: audio) {
                                    addedAudios.remove(at: idx)
                                    currentNumberAudio = addedAudios.count
                                    isAddingTwoTrack = addedAudios.count >= 2
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.vertical, 8)
            } else {
                Text("")
            }
            Spacer()
            
            if isAddingTwoTrack {
                if mixingViewModel.isPlaying {
                    Button(action: {
                        mixingViewModel.stopAudio()
                    }) {
                        Text("Stop")
                            .font(Font.title2)
                            .fontWeight(.semibold)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.vertical, 12)
                } else {
                    Button(action: {
                        let audioURLs = addedAudios.map { $0.fileURL }
                        mixingViewModel.mixAudio(audioFiles: audioURLs)
                        
                        // Tạo file export để có thể save sau này
                        Task {
                            await exportMixAudio(audioFiles: audioURLs) { url, error in
                                if let url = url {
                                    self.mixedFileURL = url
                                }
                            }
                        }
                    }) {
                        Text("Mix now")
                            .font(Font.title2)
                            .fontWeight(.semibold)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.vertical, 12)
                    .disabled(addedAudios.count < 2)
                }
                
                if let mixedFileURL = mixedFileURL, !mixingViewModel.isPlaying {
                    Button(action: {
                        isExporting = true
                    }) {
                        Label("Save Mixed File", systemImage: "square.and.arrow.down")
                            .font(Font.title2)
                            .fontWeight(.semibold)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(.discount)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.vertical, 4)
                    .fileExporter(
                        isPresented: $isExporting,
                        document: AudioFileDocument(url: mixedFileURL),
                        contentType: .m4a,
                        defaultFilename: mixedFileURL.lastPathComponent
                    ) { result in
                        switch result {
                        case .success(_):
                            break
                        case .failure(let error):
                            self.exportError = error
                        }
                    }
                }
            }
            
            if let error = exportError {
                Text("Failed to save: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .sheet(isPresented: $showSelectSourceSheet) {
            VStack(spacing: 24) {
                Capsule()
                    .fill(Color.secondary.opacity(0.5))
                    .frame(width: 50, height: 6)
                    .padding(.top, 8)
                Text("Select the source to add audio")
                    .font(.headline)
                    .padding(.bottom, 8)
                Button(action: {
                    selectedSource = .record
                    showSelectSourceSheet = false
                }) {
                    HStack {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.accentColor)
                        Text("Add audio from Record")
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                Button(action: {
                    selectedSource = .playMusic
                    showSelectSourceSheet = false
                }) {
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.accentColor)
                        Text("Add file from Music")
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .presentationDetents([.fraction(0.35)])
        }
        .sheet(item: $selectedSource) { source in
            if source == .record {
                RecordSelectionView { url in
                    let name = url.lastPathComponent
                    if !addedAudios.contains(where: { $0.fileURL == url }) {
                        addedAudios.append(AddedAudio(fileURL: url, displayName: name, source: .record))
                        currentNumberAudio = addedAudios.count
                        isAddingTwoTrack = addedAudios.count >= 2
                    }
                    selectedSource = nil
                }
            } else if source == .playMusic {
                PlayMusicSelectionView { url in
                    let name = url.deletingPathExtension().lastPathComponent
                    if !addedAudios.contains(where: { $0.fileURL == url }) {
                        addedAudios.append(AddedAudio(fileURL: url, displayName: name, source: .playMusic))
                        currentNumberAudio = addedAudios.count
                        isAddingTwoTrack = addedAudios.count >= 2
                    }
                    selectedSource = nil
                }
            }
        }
    }

    func exportMixAudio(audioFiles: [URL], completion: @escaping (URL?, Error?) -> Void) async {
        let mixComposition = AVMutableComposition()
        var maxDuration = CMTime.zero

        for fileURL in audioFiles {
            let asset = AVURLAsset(url: fileURL)
            guard let assetTrack = asset.tracks(withMediaType: .audio).first else { continue }
            do {
                let duration = try await asset.load(.duration)
                let track = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                try track?.insertTimeRange(CMTimeRange(start: .zero, duration: duration),
                                           of: assetTrack,
                                           at: .zero)
                if duration > maxDuration {
                    maxDuration = duration
                }
            } catch {
                await MainActor.run {
                    completion(nil, error)
                }
                return
            }
        }

        let tempDir = FileManager.default.temporaryDirectory
        let outputURL = tempDir.appendingPathComponent("overlap-audio-\(UUID().uuidString).m4a")

        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetAppleM4A) else {
            await MainActor.run {
                completion(nil, NSError(domain: "Overlap", code: -3, userInfo: [NSLocalizedDescriptionKey: "Could not create exporter"]))
            }
            return
        }
        exporter.outputURL = outputURL
        exporter.outputFileType = .m4a
        exporter.timeRange = CMTimeRange(start: .zero, duration: maxDuration)

        exporter.exportAsynchronously { [outputURL] in
            let status = exporter.status
            let error = exporter.error
            DispatchQueue.main.async {
                if status == .completed {
                    completion(outputURL, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
    }
}

struct MusicFile: Identifiable {
    let id = UUID()
    let fileURL: URL
    let displayName: String
    let duration: String
}
