//
//  RecordAudioView.swift
//  AudioMixer
//
//  Created by EF2025 on 18/8/25.
//

import SwiftUI

struct RecordAudioView: View {
    @ObservedObject var vm: RecordAudioViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text(vm.currentFile ?? Date().description)
                .padding()
            Spacer()
            ZStack {
                Circle()
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(width: 72, height: 72)
                Rectangle()
                    .font(.title)
                    .foregroundColor(.red)
                    .frame(width: 32, height: 32)
                    .cornerRadius(8)
            }
            .onTapGesture {
                vm.stop()
                dismiss()
            }
        }
        .onAppear {
            vm.startRecording()
        }
    }
}

#Preview {
    Record()
}
