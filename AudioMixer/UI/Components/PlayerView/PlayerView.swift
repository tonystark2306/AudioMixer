//
//  PlayerView.swift
//  AudioMixer
//
//  Created by EF2025 on 18/8/25.
//

import SwiftUI

struct PlayerView: View {
    @State private var progressAudio: CGFloat = 0.0 // 0.0 ... 1.0
    @State private var isPlaying: Bool = false
    @State private var isDragging: Bool = false
    @State private var currentTime: TimeInterval = 0 // seconds
    @State private var duration: TimeInterval = 15 * 60 // Example: 15 minutes
    
    var body: some View {
        VStack (spacing: 16) {
            HStack (spacing: 0) {
                Text("Tên bài hát")
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(height: 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(.neutral04)
                    
                    Capsule()
                        .frame(width: indicatorWidth(totalWidth: geometry.size.width - 32), height: 8) // -32 for padding
                        .padding(.horizontal, 16)
                        .foregroundColor(.neutral02)
                    
                    // Handle/knob for drag
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color("neutral02"))
                        .offset(x: knobOffset(totalWidth: geometry.size.width - 32) )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let x = max(0, min(value.location.x - 16, geometry.size.width - 32))
                                    let progress = CGFloat(x / (geometry.size.width - 32))
                                    self.progressAudio = progress
                                    self.currentTime = Double(progress) * duration
                                    self.isDragging = true
                                }
                                .onEnded { value in
                                    let x = max(0, min(value.location.x - 16, geometry.size.width - 32))
                                    let progress = CGFloat(x / (geometry.size.width - 32))
                                    self.progressAudio = progress
                                    self.currentTime = Double(progress) * duration
                                    self.isDragging = false
                                    // TODO: Call seek audio to currentTime here
                                }
                        )
                        .shadow(radius: isDragging ? 6 : 0)
                        .animation(.easeInOut, value: isDragging)
                }
                .frame(height: 28) // Enough for the knob
            }
            .frame(height: 32)
            .padding(.vertical, 8)
            
            HStack (spacing: 0) {
                Button(action: {
                    // Rewind 15s
                    let newTime = max(currentTime - 15, 0)
                    currentTime = newTime
                    progressAudio = duration > 0 ? CGFloat(newTime / duration) : 0
                    // TODO: Seek audio to newTime
                }) {
                    Image(systemName: "15.arrow.trianglehead.counterclockwise")
                        .font(.system(size: 32))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }

                Button(action: {
                    isPlaying.toggle()
                    // TODO: Play/pause audio here
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
                
                Button(action: {
                    // Forward 15s
                    let newTime = min(currentTime + 15, duration)
                    currentTime = newTime
                    progressAudio = duration > 0 ? CGFloat(newTime / duration) : 1
                    // TODO: Seek audio to newTime
                }) {
                    Image(systemName: "15.arrow.trianglehead.clockwise")
                        .font(.system(size: 32))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            
            HStack (spacing: 0) {
                Text(formatTime(currentTime))
                    .font(Font.caption)
                    .fontWeight(Font.Weight.semibold)
                    .foregroundColor(.neutral06)
                Spacer()
                Text(formatTime(duration))
                    .font(Font.caption)
                    .fontWeight(Font.Weight.semibold)
                    .foregroundColor(.neutral06)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Example: Set total duration (seconds)
            // duration = ... lấy từ audio thực tế
        }
    }
    
    // MARK: - Helper Functions
    
    private func indicatorWidth(totalWidth: CGFloat) -> CGFloat {
        return max(8, totalWidth * progressAudio)
    }
    
    private func knobOffset(totalWidth: CGFloat) -> CGFloat {
        let x = totalWidth * progressAudio
        return x + 16 - 10 // padding + shift for knob radius
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    PlayerView()
}
