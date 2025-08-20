//
//  PlayMusicSelectionView.swift
//  AudioMixer
//
//  Created by EF2025 on 20/8/25.
//

import SwiftUI
import Foundation
import AVFoundation
import Combine

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
