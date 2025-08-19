import SwiftUI
import AVFoundation

struct RecordAudioViewSample: View {
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false
    @State private var recordedURL: URL?
    @State private var recordingError: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text(isRecording ? "Đang ghi âm..." : "Ghi âm mới")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let recordedURL {
                Text("Đã lưu bản ghi:\n\(recordedURL.lastPathComponent)")
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            if let error = recordingError {
                Text(error)
                    .foregroundColor(.red)
            }

            HStack(spacing: 32) {
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                        .foregroundColor(isRecording ? .red : .blue)
                }
            }
            
            Button("Đóng") {
                dismiss()
            }
            .padding(.top, 16)
        }
        .padding()
        .onDisappear {
            if isRecording { stopRecording() }
        }
    }
    
    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        let url = FileManager.default.temporaryDirectory.appendingPathComponent("recording-\(UUID().uuidString).m4a")
                        let settings: [String: Any] = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 12000,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]
                        do {
                            let recorder = try AVAudioRecorder(url: url, settings: settings)
                            recorder.record()
                            audioRecorder = recorder
                            isRecording = true
                            recordedURL = nil
                            recordingError = nil
                        } catch {
                            recordingError = "Không thể bắt đầu ghi âm: \(error.localizedDescription)"
                        }
                    } else {
                        recordingError = "Ứng dụng không có quyền sử dụng micro."
                    }
                }
            }
        } catch {
            recordingError = "Không thể cấu hình audio session: \(error.localizedDescription)"
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        recordedURL = audioRecorder?.url
        isRecording = false
        recordingError = nil
    }
}
