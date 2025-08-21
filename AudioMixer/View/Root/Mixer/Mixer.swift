//
//  Mixer.swift
//  AudioMixer
//
//  Created by EF2025 on 18/8/25.
//

import SwiftUI
import Foundation
import AVFoundation
import Combine
import UniformTypeIdentifiers

struct Mixer: View {
    @State private var isAddingTwoTrack: Bool = false
    @State private var currentNumberAudio: Int = 0
    @State private var showSelectSourceSheet: Bool = false
    @State private var selectedSource: SourceType? = nil
    @State private var addedAudios: [AddedAudio] = []

    @State private var mixedAudioURL: URL? = nil
    @State private var showExportPicker: Bool = false
    @State private var exportURL: URL? = nil
    @State private var isMixing: Bool = false
    @State private var isTronAmThanhProcessing: Bool = false
    @State private var showMixSuccessAlert: Bool = false
    @State private var showMixErrorAlert: Bool = false
    @State private var mixErrorMessage: String = ""

    var body: some View {
        VStack {
            HStack {
                Text("Audio Mixer")
                    .font(Font.largeTitle)
                    .fontWeight(.bold)
                Spacer()

                Button(action: {
                    showSelectSourceSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .tint(Color(.systemGray4))
                        .foregroundColor(.red)
                }
            }

            Spacer()

            // Hiển thị danh sách các file đã thêm
            if !addedAudios.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(addedAudios) { audio in
                        HStack {
                            Image(systemName: audio.source == .record ? "waveform" : "music.note")
                                .foregroundColor(.accentColor)
                            Text(audio.displayName)
                                .lineLimit(1)
                            Spacer()
                            Button(action: {
                                // Xóa file khỏi danh sách
                                if let idx = addedAudios.firstIndex(of: audio) {
                                    addedAudios.remove(at: idx)
                                    currentNumberAudio = addedAudios.count
                                    isAddingTwoTrack = addedAudios.count >= 2
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.vertical, 8)
            }
            Spacer()

            if isAddingTwoTrack {
                VStack(spacing: 12) {
                    // Nút "Mix now" - nối các file liên tiếp
                    Button(action: {
                        mixAudios(urls: addedAudios.map { $0.fileURL }) { outputURL, error in
                            DispatchQueue.main.async {
                                isMixing = false
                                if let outputURL = outputURL {
                                    self.exportURL = outputURL
                                    self.showExportPicker = true
                                } else {
                                    self.mixErrorMessage = error?.localizedDescription ?? "Unknown error"
                                    self.showMixErrorAlert = true
                                }
                            }
                        }
                        isMixing = true
                    }) {
                        if isMixing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        } else {
                            Text("Mix now")
                                .font(Font.title2)
                                .fontWeight(.semibold)
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                    }
                    .disabled(isMixing || isTronAmThanhProcessing)

                    // Nút "Trộn âm thanh" - phát cùng lúc (overlap)
                    Button(action: {
                        overlapAudios(urls: addedAudios.map { $0.fileURL }) { outputURL, error in
                            DispatchQueue.main.async {
                                isTronAmThanhProcessing = false
                                if let outputURL = outputURL {
                                    self.exportURL = outputURL
                                    self.showExportPicker = true
                                } else {
                                    self.mixErrorMessage = error?.localizedDescription ?? "Unknown error"
                                    self.showMixErrorAlert = true
                                }
                            }
                        }
                        isTronAmThanhProcessing = true
                    }) {
                        if isTronAmThanhProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        } else {
                            Text("Trộn âm thanh")
                                .font(Font.title2)
                                .fontWeight(.semibold)
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                    }
                    .disabled(isTronAmThanhProcessing || isMixing)
                }
                .padding(.vertical, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .sheet(isPresented: $showSelectSourceSheet) {
            VStack(spacing: 24) {
                Capsule()
                    .fill(Color.secondary.opacity(0.5))
                    .frame(width: 50, height: 6)
                    .padding(.top, 8)
                Text("Select the source to add audio")
                    .font(.headline)
                    .padding(.bottom, 8)
                Button(action: {
                    selectedSource = .record
                    showSelectSourceSheet = false
                }) {
                    HStack {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.accentColor)
                        Text("Add audio from Record")
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                Button(action: {
                    selectedSource = .playMusic
                    showSelectSourceSheet = false
                }) {
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.accentColor)
                        Text("Add file from Music")
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .presentationDetents([.fraction(0.35)])
        }
        .sheet(item: $selectedSource) { source in
            if source == .record {
                RecordSelectionView { url in
                    let name = url.lastPathComponent
                    if !addedAudios.contains(where: { $0.fileURL == url }) {
                        addedAudios.append(AddedAudio(fileURL: url, displayName: name, source: .record))
                        currentNumberAudio = addedAudios.count
                        isAddingTwoTrack = addedAudios.count >= 2
                    }
                    selectedSource = nil
                }
            } else if source == .playMusic {
                PlayMusicSelectionView { url in
                    let name = url.deletingPathExtension().lastPathComponent
                    if !addedAudios.contains(where: { $0.fileURL == url }) {
                        addedAudios.append(AddedAudio(fileURL: url, displayName: name, source: .playMusic))
                        currentNumberAudio = addedAudios.count
                        isAddingTwoTrack = addedAudios.count >= 2
                    }
                    selectedSource = nil
                }
            }
        }
        .sheet(isPresented: $showExportPicker, onDismiss: {
            // Xoá file tạm nếu cần
            if let url = exportURL {
                try? FileManager.default.removeItem(at: url)
            }
            exportURL = nil
            showMixSuccessAlert = true
        }) {
            if let exportURL = exportURL {
                ExportDocumentPicker(exportURL: exportURL)
            }
        }
        .alert("Mix thành công!", isPresented: $showMixSuccessAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Mix thất bại", isPresented: $showMixErrorAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(mixErrorMessage)
        })
    }

    /// Mix các file audio vào 1 file tạm thời (nối liên tiếp), callback trả về URL file mới
    private func mixAudios(urls: [URL], completion: @escaping (URL?, Error?) -> Void) {
        let mixComposition = AVMutableComposition()
        guard let firstAsset = AVURLAsset(url: urls.first!) as? AVAsset else {
            completion(nil, NSError(domain: "Mix", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid asset"]))
            return
        }

        guard let track = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil, NSError(domain: "Mix", code: -2, userInfo: [NSLocalizedDescriptionKey: "Could not create track"]))
            return
        }

        var insertTime = CMTime.zero

        for url in urls {
            let asset = AVURLAsset(url: url)
            guard let assetTrack = asset.tracks(withMediaType: .audio).first else {
                continue // bỏ qua file không audio
            }
            do {
                try track.insertTimeRange(
                    CMTimeRange(start: .zero, duration: asset.duration),
                    of: assetTrack,
                    at: insertTime
                )
                insertTime = insertTime + asset.duration
            } catch {
                completion(nil, error)
                return
            }
        }

        // Lưu ra file .m4a tạm thời
        let tempDir = FileManager.default.temporaryDirectory
        let outputURL = tempDir.appendingPathComponent("mixed-audio-\(UUID().uuidString).m4a")

        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetAppleM4A) else {
            completion(nil, NSError(domain: "Mix", code: -3, userInfo: [NSLocalizedDescriptionKey: "Could not create exporter"]))
            return
        }
        exporter.outputURL = outputURL
        exporter.outputFileType = .m4a
        exporter.exportAsynchronously {
            if exporter.status == .completed {
                completion(outputURL, nil)
            } else {
                completion(nil, exporter.error)
            }
        }
    }

    /// Overlap các file audio (phát cùng lúc), callback trả về URL file mới
    private func overlapAudios(urls: [URL], completion: @escaping (URL?, Error?) -> Void) {
        // Step 1: Gather durations asynchronously
        Task {
            var durations: [CMTime] = []
            for url in urls {
                let asset = AVURLAsset(url: url)
                do {
                    let duration = try await asset.load(.duration)
                    durations.append(duration)
                } catch {
                    completion(nil, error)
                    return
                }
            }
            let maxDuration = durations.max() ?? .zero

            // Step 2: Back to main thread for exporter work, do not capture exporter inside Task context
            DispatchQueue.main.async {
                let mixComposition = AVMutableComposition()
                // Thêm mỗi audio thành một track riêng, bắt đầu tại 0
                for url in urls {
                    let asset = AVURLAsset(url: url)
                    guard let assetTrack = asset.tracks(withMediaType: .audio).first else {
                        continue // bỏ qua file không audio
                    }
                    guard let compTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                        continue
                    }
                    do {
                        try compTrack.insertTimeRange(
                            CMTimeRange(start: .zero, duration: asset.duration),
                            of: assetTrack,
                            at: .zero
                        )
                    } catch {
                        completion(nil, error)
                        return
                    }
                }

                let tempDir = FileManager.default.temporaryDirectory
                let outputURL = tempDir.appendingPathComponent("overlap-audio-\(UUID().uuidString).m4a")

                guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetAppleM4A) else {
                    completion(nil, NSError(domain: "Overlap", code: -3, userInfo: [NSLocalizedDescriptionKey: "Could not create exporter"]))
                    return
                }
                exporter.outputURL = outputURL
                exporter.outputFileType = .m4a
                exporter.timeRange = CMTimeRange(start: .zero, duration: maxDuration)

                exporter.exportAsynchronously {
                    if exporter.status == .completed {
                        completion(outputURL, nil)
                    } else {
                        completion(nil, exporter.error)
                    }
                }
            }
        }
    }
}

// MARK: - ExportDocumentPicker (SwiftUI wrapper)

struct ExportDocumentPicker: UIViewControllerRepresentable {
    let exportURL: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(exportURL: exportURL)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [exportURL], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let exportURL: URL

        init(exportURL: URL) {
            self.exportURL = exportURL
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Optionally handle cancel
        }
    }
}

#Preview {
    Root()
}

