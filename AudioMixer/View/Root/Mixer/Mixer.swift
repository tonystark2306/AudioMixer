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
    @State private var isPlaying: Bool = false
    @State private var selectedSource: SourceType? = nil
    @State private var addedAudios: [AddedAudio] = []
    @StateObject private var vm = MixerViewModel()
    
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
                Button {
                    if isPlaying {
                        vm.stop()
                        isPlaying = false
                    } else {
                        if vm.loadTrack(addedAudios: addedAudios) {
                            vm.playAll()
                            isPlaying = true
                        } else {
                            print("Failed to load tracks")
                        }
                    }
                } label: {
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


struct MusicFile: Identifiable {
    let id = UUID()
    let fileURL: URL
    let displayName: String
    let duration: String
}

// MARK: - PlayMusicSelectionView


#Preview {
    Root()
}

