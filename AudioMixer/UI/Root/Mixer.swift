//
//  Mixer.swift
//  AudioMixer
//
//  Created by EF2025 on 18/8/25.
//

import SwiftUI
import Foundation
import AVFoundation
import Combine

struct Mixer: View {
    @State private var isAddingTwoTrack: Bool = false
    @State private var currentNumberAudio: Int = 0
    @State private var showSelectSourceSheet: Bool = false
    @State private var selectedSource: SourceType? = nil
    @State private var addedAudios: [AddedAudio] = []

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
            
            // Hiển thị danh sách các file đã thêm
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
                                // Xóa file khỏi danh sách
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
                Button(action: {
                    // TODO: Thực hiện mix các file trong addedAudios
                }) {
                    Text("Mix now")
                        .font(Font.title2)
                        .fontWeight(.semibold)
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.vertical, 12)
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
                    // Lấy tên file từ url
                    let name = url.lastPathComponent
                    // Tránh duplicate
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
}

// MARK: - RecordSelectionView (unchanged)

struct RecordSelectionView: View {
    @ObservedObject private var viewModel = RecordAudioViewModel()
    var onSelect: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Select file record")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            if viewModel.recordings.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "waveform")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray)
                    Text("There is no recording")
                        .foregroundColor(.gray)
                        .font(.body)
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.recordings) { recording in
                        Button(action: {
                            onSelect(recording.fileURL)
                        }) {
                            HStack {
                                Image(systemName: "waveform")
                                    .foregroundColor(.accentColor)
                                VStack(alignment: .leading) {
                                    Text(recording.fileURL.lastPathComponent)
                                        .font(.headline)
                                    Text(Self.dateFormatter.string(from: recording.createdAt))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchRecordings()
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
}

// MARK: - MusicFile Model & PlayMusicViewModel

struct MusicFile: Identifiable {
    let id = UUID()
    let fileURL: URL
    let displayName: String
    let duration: String
}

class PlayMusicViewModel: ObservableObject {
    @Published var musicFiles: [MusicFile] = []

    func fetchMusicFiles() {
        musicFiles.removeAll()
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        // Find all mp3 files in Documents directory
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
        // For demo: add a bundled "demo" if present
        if let demoURL = Bundle.main.url(forResource: "demo", withExtension: "mp3") {
            let asset = AVURLAsset(url: demoURL)
            let durationSeconds = CMTimeGetSeconds(asset.duration)
            let minutes = Int(durationSeconds) / 60
            let seconds = Int(durationSeconds) % 60
            let durationString = String(format: "%d:%02d", minutes, seconds)
            musicFiles.append(MusicFile(fileURL: demoURL, displayName: "Demo", duration: durationString))
        }
        // Sort by displayName
        musicFiles.sort { $0.displayName < $1.displayName }
    }
}

// MARK: - PlayMusicSelectionView

struct PlayMusicSelectionView: View {
    @ObservedObject private var viewModel = PlayMusicViewModel()
    var onSelect: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Chọn file nhạc đã lưu")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            if viewModel.musicFiles.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "music.note.list")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray)
                    Text("Không có file nhạc nào")
                        .foregroundColor(.gray)
                        .font(.body)
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.musicFiles) { file in
                        Button(action: {
                            onSelect(file.fileURL)
                        }) {
                            HStack {
                                Image(systemName: "music.note")
                                    .foregroundColor(.accentColor)
                                VStack(alignment: .leading) {
                                    Text(file.displayName)
                                        .font(.headline)
                                    Text(file.duration)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchMusicFiles()
        }
    }
}

#Preview {
    Root()
}

