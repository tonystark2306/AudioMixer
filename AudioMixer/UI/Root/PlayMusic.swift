//
//  record.swift
//  AudioMixer
//
//  Created by EF2025 on 18/8/25.
//

import SwiftUI

struct PlayMusic: View {
    @State private var showPlayer = false
    @StateObject private var audioManager = AudioManager.shared
    
    let songs = [
        ("aloha", "Aloha", "4:10"),
        ("avengers", "Avengers", "2:03"),
        ("demo", "Demo", "0:42"),
        ("iloveu3000", "I Love You 3000", "3:29"),
        ("portals", "Portals", "3:23")
    ]

    var body: some View {
        VStack (spacing: 8) {
            HStack {
                Text("All music")
                    .font(Font.largeTitle)
                    .fontWeight(.bold)
                    .padding(8)
                Spacer()
                
                Button(action: {
                    
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .tint(Color(.systemGray4))
                        .foregroundColor(.red)
                        .frame(width: 64, height: 64)
                }
            }
            List {
                ForEach(songs, id: \.0) { song in
                    AudioCell(songName: song.0, displayName: song.1, duration: song.2)
                        .onTapGesture {
                            audioManager.loadAndPlay(songName: song.0)
                            showPlayer = true
                        }
                }
            }
            .listStyle(.plain)
            .padding(.horizontal, -8)
            Spacer()
        }
        .sheet(isPresented: $showPlayer) {
            PlayerView()
                .presentationDetents([.fraction(0.35)])
        }
    }
}
