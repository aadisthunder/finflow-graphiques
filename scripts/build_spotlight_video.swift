import Foundation
import AVFoundation
import AppKit
import CoreGraphics

struct StateSegment {
    let stateName: String
    let duration: Double
}

func createPixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
    var pixelBuffer: CVPixelBuffer?
    let options: [CFString: Any] = [
        kCVPixelBufferCGImageCompatibilityKey: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey: true
    ]
    let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)
    return status == kCVReturnSuccess ? pixelBuffer : nil
}

func renderCrossfade(currentImage: CGImage, nextImage: CGImage?, blend: Double, width: Int, height: Int, buffer: CVPixelBuffer) {
    CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
    defer { CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0)) }
    
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
    ) else { return }

    let fullRect = CGRect(x: 0, y: 0, width: width, height: height)
    context.interpolationQuality = .high

    if let next = nextImage, blend > 0.0 {
        // Draw base image
        context.setAlpha(1.0)
        context.draw(currentImage, in: fullRect)
        // Blend next image on top
        context.setAlpha(CGFloat(blend))
        context.draw(next, in: fullRect)
    } else {
        context.setAlpha(1.0)
        context.draw(currentImage, in: fullRect)
    }
}

func main() {
    let width = 1920
    let height = 1080
    let fps: Int32 = 30
    let crossfadeDuration = 0.25 // Smooth 250ms crossfade between spotlight states

    // The 23 Spotlight States synchronized to audio word-for-word using ground-truth Gemini 3.8 Flash timestamps
    let segments: [StateSegment] = [
        // Slide 1: Hero Overview (14.78s total)
        StateSegment(stateName: "1", duration: 14.78),

        // Slide 2: Raju's Story (15.78s total)
        StateSegment(stateName: "2a", duration: 6.95),   // 0.00s - 6.95s: "At 4:30 AM, Raju needs ₹3,000 wholesale inventory..."
        StateSegment(stateName: "2b", duration: 5.85),   // 6.95s - 12.80s: "Slow banking forces him into predatory lenders charging over 300% APR..."
        StateSegment(stateName: "2c", duration: 2.98),   // 12.80s - 15.78s: "trapping his family in debt."

        // Slide 3: Traditional Banking Fails (13.42s total)
        StateSegment(stateName: "3a", duration: 7.15),   // 0.00s - 7.15s: "Traditional banks fail informal vendors by demanding collateral..."
        StateSegment(stateName: "3b", duration: 6.27),   // 7.15s - 13.42s: "When heatwaves or floods hit, lenders offer zero relief..."

        // Slide 4: 4 Pillars & Live Telemetry (16.98s total)
        StateSegment(stateName: "4a", duration: 10.00),  // 0.00s - 10.00s: 4 Pillars introduction
        StateSegment(stateName: "4b", duration: 6.98),   // 10.00s - 16.98s: Live Telemetry ₹200 UPI Split Bar

        // Slide 5: Raju's Day & Soundbox (14.82s total)
        StateSegment(stateName: "5a", duration: 7.40),   // 0.00s - 7.40s: "At 4:30 AM, smart soundbox disburses ₹3,000 in seconds..."
        StateSegment(stateName: "5b", duration: 7.42),   // 7.40s - 14.82s: "Customer UPI payments auto-settle loan in micro-slices..."

        // Slide 6: Engineering Architecture (14.02s total)
        StateSegment(stateName: "6a", duration: 6.65),   // 0.00s - 6.65s: "Built on India's DPI, FinFlow integrates OCEN 4.0..."
        StateSegment(stateName: "6b", duration: 2.58),   // 6.65s - 9.23s: "real-time UPI settlement webhooks..."
        StateSegment(stateName: "6c", duration: 4.79),   // 9.23s - 14.02s: "and our Velocity TrustScore that replaces traditional credit scores."

        // Slide 7: Unit Economics (14.30s total)
        StateSegment(stateName: "7a", duration: 9.40),   // 0.00s - 9.40s: "Flat ₹20 fee per daily cycle delivers 86.8% net margin..."
        StateSegment(stateName: "7b", duration: 4.90),   // 9.40s - 14.30s: "and a 14.8 times lifetime value to CAC ratio."

        // Slide 8: Market Opportunity & TAM (14.50s total)
        StateSegment(stateName: "8a", duration: 5.60),   // 0.00s - 5.60s: "40M vendors represent an $18 Billion demand..."
        StateSegment(stateName: "8b", duration: 4.20),   // 5.60s - 9.80s: "Scaling to 250,000 merchants across eight trading hubs..."
        StateSegment(stateName: "8c", duration: 4.70),   // 9.80s - 14.50s: "unlocks 18 million dollars in annual recurring revenue."

        // Slide 9: Implementation Roadmap (13.70s total)
        StateSegment(stateName: "9a", duration: 5.85),   // 0.00s - 5.85s: "Phase 1: Pilot with 1,000 vendors in Delhi's Azadpur Mandi..."
        StateSegment(stateName: "9b", duration: 2.25),   // 5.85s - 8.10s: "Phase 2: Scale with Small Finance Banks..."
        StateSegment(stateName: "9c", duration: 5.60),   // 8.10s - 13.70s: "Phase 3: National Scale to 100,000 merchants across 15 states."

        // Slide 10: Conclusion & Dignity Restored (10.48s total)
        StateSegment(stateName: "10a", duration: 5.10),  // 0.00s - 5.10s: "FinFlow saves vendors over ₹7,500 every month..."
        StateSegment(stateName: "10b", duration: 5.38)   // 5.10s - 10.48s: "restoring economic freedom and dignity to the backbone of our economy. Thank you."
    ]

    let tempVideoUrl = URL(fileURLWithPath: "/tmp/finflow_spotlight_raw.mp4")
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

    var currentGlobalFrame: Int64 = 0

    print("🎬 Rendering Spotlight & Subtitle 1080p Presentation Video...")

    // Preload CGImages
    var images: [String: CGImage] = [:]
    for seg in segments {
        if images[seg.stateName] != nil { continue }
        let path = "presentation/spotlight_frames/state_\(seg.stateName).png"
        guard let nsImg = NSImage(contentsOfFile: path),
              let cg = nsImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Error loading image at \(path)")
            continue
        }
        images[seg.stateName] = cg
    }

    for (index, seg) in segments.enumerated() {
        guard let currentImage = images[seg.stateName] else { continue }
        let nextSegment = (index + 1 < segments.count) ? segments[index + 1] : nil
        let nextImage = nextSegment != nil ? images[nextSegment!.stateName] : nil

        let totalFrames = Int64(round(seg.duration * Double(fps)))
        let crossfadeFrames = Int64(round(crossfadeDuration * Double(fps)))

        print("  - State \(seg.stateName): Rendering \(totalFrames) frames (\(seg.duration)s)...")

        for f in 0..<totalFrames {
            while !writerInput.isReadyForMoreMediaData {
                usleep(1000)
            }

            var blend: Double = 0.0
            let framesRemaining = totalFrames - f
            if framesRemaining <= crossfadeFrames && nextImage != nil {
                blend = Double(crossfadeFrames - framesRemaining) / Double(crossfadeFrames)
            }

            guard let buffer = createPixelBuffer(width: width, height: height) else { continue }
            renderCrossfade(
                currentImage: currentImage,
                nextImage: nextImage,
                blend: blend,
                width: width,
                height: height,
                buffer: buffer
            )

            let presentationTime = CMTime(value: currentGlobalFrame, timescale: fps)
            adaptor.append(buffer, withPresentationTime: presentationTime)
            currentGlobalFrame += 1
        }
    }

    writerInput.markAsFinished()

    let semaphore = DispatchSemaphore(value: 0)
    assetWriter.finishWriting {
        print("✅ Raw video writing completed!")
        semaphore.signal()
    }
    semaphore.wait()

    // Mux with Gemini 3.1 studio audio
    print("🎵 Muxing with Gemini 3.1 Studio Voiceover (presentation/audio/full_voiceover.wav)...")
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
            print("\n🎉 SUCCESS: Spotlight presentation video exported: FinFlow_Demo_Presentation.mp4")
        } else {
            print("\n❌ ERROR: Export failed: \(String(describing: exportSession.error))")
        }
        exportSemaphore.signal()
    }
    exportSemaphore.wait()
}

main()
