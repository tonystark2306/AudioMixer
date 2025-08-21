//
//  record.swift
//  AudioMixer
//
//  Created by EF2025 on 18/8/25.
//

import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

let bundledSongs: [(String, String, String)] = [
    ("aloha", "Aloha", "4:10"),
    ("avengers", "Avengers", "2:03"),
    ("demo", "Demo", "0:42"),
    ("iloveu3000", "I Love You 3000", "3:29"),
    ("portals", "Portals", "3:23")
]

struct PlayMusic: View {
    @State private var showPlayer = false
    @State private var showDocumentPicker = false
    @StateObject private var audioManager = AudioManager.shared

    @State var songs: [(String, String, String)] = bundledSongs
    
    var body: some View {
        VStack {
            HStack {
                Text("All music")
                    .font(Font.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                
                Button(action: {
                    showDocumentPicker = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .tint(Color(.systemGray4))
                        .foregroundColor(.red)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .sheet(isPresented: $showPlayer) {
            PlayerView()
                .presentationDetents([.fraction(0.35)])
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { url in
                if let url = url {
                    addSong(from: url)
                }
            }
        }
    }
    
    private func addSong(from url: URL) {
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileName = url.lastPathComponent
        let destURL = documents.appendingPathComponent(fileName)

        var songKey = destURL.deletingPathExtension().lastPathComponent
        if !fileManager.fileExists(atPath: destURL.path) {
            do {
                try fileManager.copyItem(at: url, to: destURL)
            } catch {
                print("Failed to copy file: \(error)")
                return
            }
        }
        
        let asset = AVURLAsset(url: destURL)
        let durationSeconds = CMTimeGetSeconds(asset.duration)
        let minutes = Int(durationSeconds) / 60
        let seconds = Int(durationSeconds) % 60
        let durationString = String(format: "%d:%02d", minutes, seconds)
        
        let displayName = destURL.deletingPathExtension().lastPathComponent
        
        songs.append((songKey, displayName, durationString))
    }
}


struct DocumentPicker: UIViewControllerRepresentable {
    var completion: (URL?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.mp3])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (URL?) -> Void

        init(completion: @escaping (URL?) -> Void) {
            self.completion = completion
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            completion(urls.first)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            completion(nil)
        }
    }
}
