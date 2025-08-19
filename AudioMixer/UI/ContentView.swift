//
//  ContentView.swift
//  AudioMixer
//
//  Created by EF2025 on 14/8/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack (spacing: 16) {
            Image(systemName: "globe")
            Image(systemName: "microphone.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
