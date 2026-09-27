import Foundation
import AVFoundation

guard CommandLine.arguments.count >= 4 else {
    print("Usage: swift mux_video_audio.swift <video_in> <audio_in> <output_mp4>")
    exit(1)
}

let videoUrl = URL(fileURLWithPath: CommandLine.arguments[1])
let audioUrl = URL(fileURLWithPath: CommandLine.arguments[2])
let outputUrl = URL(fileURLWithPath: CommandLine.arguments[3])

// Remove existing output if present
try? FileManager.default.removeItem(at: outputUrl)

let composition = AVMutableComposition()

let videoAsset = AVURLAsset(url: videoUrl)
let audioAsset = AVURLAsset(url: audioUrl)

let semaphore = DispatchSemaphore(value: 0)

guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else {
    print("Error: No video track found in \(videoUrl.path)")
    exit(1)
}

guard let compVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    print("Error: Could not create composition video track")
    exit(1)
}

let videoDuration = videoAsset.duration
let timeRange = CMTimeRange(start: .zero, duration: videoDuration)

do {
    try compVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
} catch {
    print("Error inserting video track: \(error)")
    exit(1)
}

// Add audio track
if let audioTrack = audioAsset.tracks(withMediaType: .audio).first {
    if let compAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
        let audioDuration = min(audioAsset.duration, videoDuration)
        let audioRange = CMTimeRange(start: .zero, duration: audioDuration)
        do {
            try compAudioTrack.insertTimeRange(audioRange, of: audioTrack, at: .zero)
            print("Audio track added successfully (\(CMTimeGetSeconds(audioDuration))s)")
        } catch {
            print("Error inserting audio track: \(error)")
        }
    }
}

guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
    print("Error: Could not create AVAssetExportSession")
    exit(1)
}

exportSession.outputURL = outputUrl
exportSession.outputFileType = .mp4
exportSession.shouldOptimizeForNetworkUse = true

print("Exporting muxed video to \(outputUrl.path)...")
exportSession.exportAsynchronously {
    if exportSession.status == .completed {
        print("SUCCESS: Export completed successfully!")
    } else {
        print("ERROR: Export failed with status \(exportSession.status.rawValue): \(String(describing: exportSession.error))")
    }
    semaphore.signal()
}

semaphore.wait()
