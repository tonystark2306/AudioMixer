//
//  RecordAudioViewModel.swift
//  AudioMixer
//
//  Created by iKame Elite Fresher 2025 on 8/18/25.
//

import Foundation
import Combine
import AVFoundation

class RecordAudioViewModel: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var timeRecorded: TimeInterval = 0
    @Published var currentFile: String?
    @Published var recordings: [Recording] = []
    
    var recorder: AVAudioRecorder?
    var recordingSession = AVAudioSession.sharedInstance()
    
    override init() {
        super.init()
        fetchRecordings()
    }
    
    func requestMicPermission(_ completion: @escaping (Bool) -> Void) {
        recordingSession.requestRecordPermission { allowed in
            DispatchQueue.main.async { completion(allowed) }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try recordingSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "ddMMyyyy_HHmmss"
            let filename = formatter.string(from: Date()) + ".m4a"
            currentFile = filename
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
            
            recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            recorder?.delegate = self
            recorder?.record()
            
            isRecording = true
        } catch {
            print("Failed to record: \(error)")
        }
    }
    
    func stop() {
        guard isRecording else { return }
        recorder?.stop()
        recorder = nil
        isRecording = false
        fetchRecordings()
    }
    
    func fetchRecordings() {
        recordings.removeAll()
        let files = try? FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil)
        
        files?.filter { $0.pathExtension == "m4a" }.forEach { file in
            let attr = try? FileManager.default.attributesOfItem(atPath: file.path)
            let created = attr?[.creationDate] as? Date ?? Date()
            recordings.append(Recording(fileURL: file, createdAt: created))
        }
        
        recordings.sort { $0.createdAt > $1.createdAt }
    }
}

extension RecordAudioViewModel: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Encode error: \(error?.localizedDescription ?? "unknown")")
    }
}
