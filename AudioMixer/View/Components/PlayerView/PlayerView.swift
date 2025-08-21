//
//  PlayerView.swift
//  AudioMixer
//
//  Created by EF2025 on 18/8/25.
//
import SwiftUI

struct PlayerView: View {
    @StateObject private var audioManager = AudioManager.shared
    @State private var isDragging: Bool = false
    
    var body: some View {
        VStack (spacing: 16) {
            HStack (spacing: 0) {
                Text(audioManager.currentSong.isEmpty ? "No Song" : audioManager.currentSong.capitalized)
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
                        .frame(width: indicatorWidth(totalWidth: geometry.size.width - 32), height: 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(.neutral02)
                    
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.neutral02)
                        .offset(x: knobOffset(totalWidth: geometry.size.width - 32) )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let x = max(0, min(value.location.x - 16, geometry.size.width - 32))
                                    let progress = CGFloat(x / (geometry.size.width - 32))
                                    _ = Double(progress) * audioManager.duration
                                    isDragging = true
                                }
                                .onEnded { value in
                                    let x = max(0, min(value.location.x - 16, geometry.size.width - 32))
                                    let progress = CGFloat(x / (geometry.size.width - 32))
                                    let newTime = Double(progress) * audioManager.duration
                                    audioManager.seek(to: newTime)
                                    isDragging = false
                                }
                        )
                        .shadow(radius: isDragging ? 6 : 0)
                        .animation(.easeInOut, value: isDragging)
                }
                .frame(height: 28)
            }
            .frame(height: 32)
            .padding(.vertical, 8)
            
            HStack (spacing: 0) {
                Button(action: {
                    audioManager.skipBackward()
                }) {
                    Image(systemName: "15.arrow.trianglehead.counterclockwise")
                        .font(.system(size: 32))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }

                Button(action: {
                    audioManager.togglePlayPause()
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
                
                Button(action: {
                    audioManager.skipForward()
                }) {
                    Image(systemName: "15.arrow.trianglehead.clockwise")
                        .font(.system(size: 32))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            
            HStack (spacing: 0) {
                Text(formatTime(audioManager.currentTime))
                    .font(Font.caption)
                    .fontWeight(Font.Weight.semibold)
                    .foregroundColor(.neutral06)
                Spacer()
                Text(formatTime(audioManager.duration))
                    .font(Font.caption)
                    .fontWeight(Font.Weight.semibold)
                    .foregroundColor(.neutral06)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func indicatorWidth(totalWidth: CGFloat) -> CGFloat {
        guard audioManager.duration > 0 else { return 8 }
        let progress = CGFloat(audioManager.currentTime / audioManager.duration)
        return max(8, totalWidth * progress)
    }
    
    private func knobOffset(totalWidth: CGFloat) -> CGFloat {
        guard audioManager.duration > 0 else { return 16 - 10 }
        let progress = CGFloat(audioManager.currentTime / audioManager.duration)
        let x = totalWidth * progress
        return x + 16 - 10
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
