//
//  File.swift
//  AudioMixer
//
//  Created by EF2025 on 20/8/25.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

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
