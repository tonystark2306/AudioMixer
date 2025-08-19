//
//  record.swift
//  AudioMixer
//
//  Created by EF2025 on 18/8/25.
//

import SwiftUI

struct PlayMusic: View {
    @State private var showPlayer = false

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
                AudioCell()
                    .onTapGesture {
                        showPlayer = true
                    }
                AudioCell()
                    .onTapGesture {
                        showPlayer = true
                    }
                AudioCell()
                    .onTapGesture {
                        showPlayer = true
                    }
                AudioCell()
                    .onTapGesture {
                        showPlayer = true
                    }
            }
            .listStyle(.plain)
            .padding(.horizontal, -8) // Remove side padding
            Spacer()
        }
        .sheet(isPresented: $showPlayer) {
            PlayerView()
                .presentationDetents([.fraction(0.35)])
        }
    }
}

#Preview {
    PlayMusic()
}
