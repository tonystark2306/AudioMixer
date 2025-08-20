//
//  AudioCell.swift
//  AudioMixer
//
//  Created by EF2025 on 18/8/25.
//

import SwiftUI

struct AudioCell: View {
    let songName: String
    let displayName: String
    let duration: String
    
    init(songName: String = "demo", displayName: String = "Tên file audio", duration: String = "0:54") {
        self.songName = songName
        self.displayName = displayName
        self.duration = duration
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 8) {
            HStack {
                Text(displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            HStack {
                Text("15:00")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                Spacer()
                Text(duration)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AudioCell(songName: "demo", displayName: "Tên file audio", duration: "00:00")
}
