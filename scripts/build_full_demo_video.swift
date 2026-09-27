import Foundation
import AVFoundation
import AppKit
import CoreGraphics

func pixelBufferFromCGImage(image: CGImage, width: Int, height: Int) -> CVPixelBuffer? {
    var pixelBuffer: CVPixelBuffer?
    let options: [CFString: Any] = [
        kCVPixelBufferCGImageCompatibilityKey: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey: true
    ]
    let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)
    guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
        return nil
    }

    CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(buffer)
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

    guard let context = CGContext(
        data: pixelData,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
        space: rgbColorSpace,
        bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
    ) else {
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        return nil
    }

    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
    return buffer
}

func main() {
    let width = 1920
    let height = 1080
    let fps: Int32 = 30

    // Exact durations of slide_1.wav to slide_10.wav
    let slideDurations: [(Int, Double)] = [
        (1, 14.28),
        (2, 15.28),
        (3, 12.92),
        (4, 16.48),
        (5, 14.32),
        (6, 13.52),
        (7, 13.80),
        (8, 14.00),
        (9, 13.20),
        (10, 10.48)
    ]

    let tempVideoUrl = URL(fileURLWithPath: "/tmp/finflow_raw_video.mp4")
    try? FileManager.default.removeItem(at: tempVideoUrl)

    guard let assetWriter = try? AVAssetWriter(outputURL: tempVideoUrl, fileType: .mp4) else {
        print("Error: Could not initialize AVAssetWriter")
        exit(1)
    }

    let outputSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: width,
        AVVideoHeightKey: height
    ]

    let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
    writerInput.expectsMediaDataInRealTime = false

    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
        assetWriterInput: writerInput,
        sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height
        ]
    )

    assetWriter.add(writerInput)
    assetWriter.startWriting()
    assetWriter.startSession(atSourceTime: .zero)

    var currentFrame: Int64 = 0

    print("Encoding video frames for 10 slides...")
    for (slideIndex, duration) in slideDurations {
        let imagePath = "presentation/screenshots/slide_\(slideIndex).png"
        guard let nsImage = NSImage(contentsOfFile: imagePath) else {
            print("Error loading image at \(imagePath)")
            continue
        }
        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Error converting to CGImage: \(imagePath)")
            continue
        }
        guard let pixelBuffer = pixelBufferFromCGImage(image: cgImage, width: width, height: height) else {
            print("Error creating pixel buffer for slide \(slideIndex)")
            continue
        }

        let numFrames = Int64(round(duration * Double(fps)))
        for _ in 0..<numFrames {
            while !writerInput.isReadyForMoreMediaData {
                usleep(1000)
            }
            let presentationTime = CMTime(value: currentFrame, timescale: fps)
            adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
            currentFrame += 1
        }
        print("  - Slide \(slideIndex): \(duration)s (\(numFrames) frames encoded)")
    }

    writerInput.markAsFinished()

    let semaphore = DispatchSemaphore(value: 0)
    assetWriter.finishWriting {
        print("Raw video writing completed!")
        semaphore.signal()
    }
    semaphore.wait()

    // Now merge with full audio
    print("Muxing video with Gemini 3.1 studio audio (presentation/audio/full_voiceover.wav)...")
    let finalOutputUrl = URL(fileURLWithPath: "FinFlow_Demo_Presentation.mp4")
    try? FileManager.default.removeItem(at: finalOutputUrl)

    let composition = AVMutableComposition()
    let rawVideoAsset = AVURLAsset(url: tempVideoUrl)
    let audioAsset = AVURLAsset(url: URL(fileURLWithPath: "presentation/audio/full_voiceover.wav"))

    guard let videoTrack = rawVideoAsset.tracks(withMediaType: .video).first,
          let compVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
        print("Error: Could not extract video track")
        exit(1)
    }

    let rawDuration = rawVideoAsset.duration
    try? compVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: rawDuration), of: videoTrack, at: .zero)

    if let audioTrack = audioAsset.tracks(withMediaType: .audio).first,
       let compAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
        let audioDuration = min(audioAsset.duration, rawDuration)
        try? compAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: audioDuration), of: audioTrack, at: .zero)
        print("Audio track synchronized successfully (\(CMTimeGetSeconds(audioDuration))s)")
    }

    guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
        print("Error creating export session")
        exit(1)
    }

    exportSession.outputURL = finalOutputUrl
    exportSession.outputFileType = .mp4
    exportSession.shouldOptimizeForNetworkUse = true

    let exportSemaphore = DispatchSemaphore(value: 0)
    exportSession.exportAsynchronously {
        if exportSession.status == .completed {
            print("\n🎉 SUCCESS: Final presentation video generated: FinFlow_Demo_Presentation.mp4")
        } else {
            print("\n❌ ERROR: Export failed: \(String(describing: exportSession.error))")
        }
        exportSemaphore.signal()
    }
    exportSemaphore.wait()
}

main()
