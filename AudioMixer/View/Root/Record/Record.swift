//
//  record.swift
//  AudioMixer
//
//  Created by EF2025 on 18/8/25.
//

import SwiftUI
import AVFoundation

struct Record: View {
    @State private var isPresentingRecorder = false
    @State private var player: AVAudioPlayer?
    @StateObject private var vm = RecordAudioViewModel()
    
    var body: some View {
        VStack (spacing: 8) {
            HStack {
                Text("All record")
                    .font(Font.largeTitle)
                    .fontWeight(Font.Weight.bold)
                Spacer()
            }
            
            List {
                ForEach(vm.recordings) {
                    recording in
                    HStack {
                        Text(recording.fileURL.lastPathComponent)
                            .lineLimit(1)
                        Spacer()
                        Button(action: {
                            playRecording(url: recording.fileURL)
                        }) {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .listStyle(.plain)
            Spacer()
            
            Button(action: {
                isPresentingRecorder = true
            }) {
                ZStack {
                    Circle()
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 72, height: 72)
                    Circle()
                        .font(.title)
                        .foregroundColor(.red)
                        .frame(width: 64, height: 64)
                }
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(.neutral01)
        .sheet(isPresented: $isPresentingRecorder) {
            RecordAudioView(vm: vm)
                .presentationDetents([.fraction(0.35)])
        }
    }
    
    private func playRecording(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Playback failed: \(error)")
        }
    }
}

#Preview {
    Record()
}
