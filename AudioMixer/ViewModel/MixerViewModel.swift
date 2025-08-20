//
//  SwiftUIView.swift
//  AudioMixer
//
//  Created by EF2025 on 20/8/25.
//

import SwiftUI
import AVFAudio

struct MixerViewModel: View {
    
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var mixer: AVAudioMixerNode = AVAudioMixerNode()
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    MixerViewModel()
}
