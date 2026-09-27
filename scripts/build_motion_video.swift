import Foundation
import AVFoundation
import AppKit
import CoreGraphics

struct CameraKeyframe {
    let time: Double      // Seconds within the slide
    let scale: Double     // Zoom factor (1.0 = full frame, 1.4 = 140% zoom)
    let focusX: Double    // Normalized center X (0.0 = left, 1.0 = right)
    let focusY: Double    // Normalized center Y (0.0 = top, 1.0 = bottom)
}

struct SlideChoreography {
    let slideIndex: Int
    let duration: Double
    let keyframes: [CameraKeyframe]
}

func smoothstep(_ t: Double) -> Double {
    let c = max(0.0, min(1.0, t))
    return c * c * (3.0 - 2.0 * c)
}

func getCameraState(for time: Double, in keyframes: [CameraKeyframe]) -> (scale: Double, x: Double, y: Double) {
    guard !keyframes.isEmpty else { return (1.0, 0.5, 0.5) }
    if time <= keyframes.first!.time {
        let f = keyframes.first!
        return (f.scale, f.focusX, f.focusY)
    }
    if time >= keyframes.last!.time {
        let l = keyframes.last!
        return (l.scale, l.focusX, l.focusY)
    }

    for i in 0..<(keyframes.count - 1) {
        let kf1 = keyframes[i]
        let kf2 = keyframes[i + 1]
        if time >= kf1.time && time <= kf2.time {
            let span = kf2.time - kf1.time
            let t = span > 0.0 ? (time - kf1.time) / span : 0.0
            let ease = smoothstep(t)
            let s = kf1.scale + (kf2.scale - kf1.scale) * ease
            let x = kf1.focusX + (kf2.focusX - kf1.focusX) * ease
            let y = kf1.focusY + (kf2.focusY - kf1.focusY) * ease
            return (s, x, y)
        }
    }
    let l = keyframes.last!
    return (l.scale, l.focusX, l.focusY)
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

func renderFrame(cgImage: CGImage, scale: Double, focusX: Double, focusY: Double, width: Int, height: Int, buffer: CVPixelBuffer) {
    let cropW = Double(width) / scale
    let cropH = Double(height) / scale
    
    var cropX = (focusX * Double(width)) - (cropW / 2.0)
    var cropY = (focusY * Double(height)) - (cropH / 2.0)
    
    cropX = max(0, min(cropX, Double(width) - cropW))
    cropY = max(0, min(cropY, Double(height) - cropH))
    
    let cropRect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
    guard let cropped = cgImage.cropping(to: cropRect) else { return }

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

    context.interpolationQuality = .high
    context.draw(cropped, in: CGRect(x: 0, y: 0, width: width, height: height))
}

func main() {
    let width = 1920
    let height = 1080
    let fps: Int32 = 30

    // Cinematic Camera Choreography for all 10 slides
    // Synchronized 1:1 with Gemini Studio Voiceover (Charon) & slide content
    let choreography: [SlideChoreography] = [
        // Slide 1: Hero Overview (14.28s + 0.50s pause = 14.78s)
        SlideChoreography(slideIndex: 1, duration: 14.78, keyframes: [
            CameraKeyframe(time: 0.0, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 3.0, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 8.0, scale: 1.14, focusX: 0.50, focusY: 0.55),
            CameraKeyframe(time: 14.78, scale: 1.14, focusX: 0.50, focusY: 0.55)
        ]),

        // Slide 2: Raju's Story (15.28s + 0.50s pause = 15.78s)
        // Zoom aligns verbatim with spoken words:
        // "At 4:30 AM, Raju needs 3,000 rupees" -> Card 1: 4:30 AM Mandi (Needs ₹3,000 Morning Capital)
        // "Slow banking forces him into predatory lenders charging over 300 percent APR" -> Card 2: Charging Over 300% APR
        // "trapping his family in debt" -> Card 3: Zero Weather Relief: Trapping Family in Debt
        SlideChoreography(slideIndex: 2, duration: 15.78, keyframes: [
            CameraKeyframe(time: 0.0, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 1.2, scale: 1.0, focusX: 0.50, focusY: 0.50),
            // Zoom to Card 1: 4:30 AM Mandi (Needs ₹3,000 Morning Capital)
            CameraKeyframe(time: 2.8, scale: 1.36, focusX: 0.22, focusY: 0.55),
            CameraKeyframe(time: 5.6, scale: 1.36, focusX: 0.22, focusY: 0.55),
            // Pan to Card 2: Predatory Debt (Charging Over 300% APR)
            CameraKeyframe(time: 7.2, scale: 1.36, focusX: 0.50, focusY: 0.55),
            CameraKeyframe(time: 10.4, scale: 1.36, focusX: 0.50, focusY: 0.55),
            // Pan to Card 3: Weather Shock (Trapping Family in Debt)
            CameraKeyframe(time: 12.0, scale: 1.36, focusX: 0.78, focusY: 0.55),
            CameraKeyframe(time: 15.78, scale: 1.36, focusX: 0.78, focusY: 0.55)
        ]),

        // Slide 3: Comparison Table (12.92s + 0.50s pause = 13.42s)
        // Zoom to Underwriting/EMI comparison, then down to Climate Shock row
        SlideChoreography(slideIndex: 3, duration: 13.42, keyframes: [
            CameraKeyframe(time: 0.0, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 1.5, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 4.5, scale: 1.26, focusX: 0.65, focusY: 0.48),
            CameraKeyframe(time: 7.5, scale: 1.26, focusX: 0.65, focusY: 0.48),
            CameraKeyframe(time: 10.5, scale: 1.30, focusX: 0.75, focusY: 0.68),
            CameraKeyframe(time: 13.42, scale: 1.30, focusX: 0.75, focusY: 0.68)
        ]),

        // Slide 4: 4 Pillars & Live Telemetry (16.48s + 0.50s pause = 16.98s)
        // Zoom into 4 pillars, then punch down directly onto ₹200 UPI Split Bar
        SlideChoreography(slideIndex: 4, duration: 16.98, keyframes: [
            CameraKeyframe(time: 0.0, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 2.0, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 5.5, scale: 1.22, focusX: 0.50, focusY: 0.35),
            CameraKeyframe(time: 8.5, scale: 1.22, focusX: 0.50, focusY: 0.35),
            // Punch-in to live ₹200 UPI Split Bar at bottom
            CameraKeyframe(time: 11.0, scale: 1.40, focusX: 0.50, focusY: 0.80),
            CameraKeyframe(time: 16.98, scale: 1.40, focusX: 0.50, focusY: 0.80)
        ]),

        // Slide 5: Raju's Day & Soundbox Terminal (14.32s + 0.50s pause = 14.82s)
        // Zoom to Soundbox hardware on right, then pan to retail settlement & zero-debt evening
        SlideChoreography(slideIndex: 5, duration: 14.82, keyframes: [
            CameraKeyframe(time: 0.0, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 1.5, scale: 1.0, focusX: 0.50, focusY: 0.50),
            // Focus on smart soundbox terminal
            CameraKeyframe(time: 3.5, scale: 1.34, focusX: 0.75, focusY: 0.48),
            CameraKeyframe(time: 6.5, scale: 1.34, focusX: 0.75, focusY: 0.48),
            // Pan to retail UPI auto-settle timeline steps
            CameraKeyframe(time: 9.0, scale: 1.30, focusX: 0.32, focusY: 0.55),
            CameraKeyframe(time: 11.5, scale: 1.32, focusX: 0.32, focusY: 0.75),
            CameraKeyframe(time: 14.82, scale: 1.32, focusX: 0.32, focusY: 0.75)
        ]),

        // Slide 6: Engineering & System Architecture (13.52s + 0.50s pause = 14.02s)
        // Zoom to Bank Dashboard / OCEN 4.0, then Real-Time Webhook Engine, then Velocity TrustScore ML
        SlideChoreography(slideIndex: 6, duration: 14.02, keyframes: [
            CameraKeyframe(time: 0.0, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 1.5, scale: 1.0, focusX: 0.50, focusY: 0.50),
            // Focus on Bank Portal & OCEN 4.0 Gateway
            CameraKeyframe(time: 3.5, scale: 1.32, focusX: 0.30, focusY: 0.55),
            CameraKeyframe(time: 5.5, scale: 1.32, focusX: 0.30, focusY: 0.55),
            // Pan to Real-Time Webhook Engine card
            CameraKeyframe(time: 7.2, scale: 1.35, focusX: 0.75, focusY: 0.35),
            CameraKeyframe(time: 9.0, scale: 1.35, focusX: 0.75, focusY: 0.35),
            // Pan to Velocity TrustScore ML card
            CameraKeyframe(time: 10.5, scale: 1.35, focusX: 0.75, focusY: 0.58),
            CameraKeyframe(time: 14.02, scale: 1.35, focusX: 0.75, focusY: 0.58)
        ]),

        // Slide 7: Business Model & Unit Economics (13.80s + 0.50s pause = 14.30s)
        // Zoom to ₹20 Flat Fee & 86.8% Net Margin, then pan to 14.8x LTV/CAC
        SlideChoreography(slideIndex: 7, duration: 14.30, keyframes: [
            CameraKeyframe(time: 0.0, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 1.5, scale: 1.0, focusX: 0.50, focusY: 0.50),
            // Zoom to ₹20 Flat Fee and 86.8% Net Margin cards
            CameraKeyframe(time: 3.5, scale: 1.36, focusX: 0.28, focusY: 0.45),
            CameraKeyframe(time: 7.5, scale: 1.36, focusX: 0.28, focusY: 0.45),
            // Pan to 14.8x LTV/CAC Ratio card
            CameraKeyframe(time: 9.5, scale: 1.38, focusX: 0.61, focusY: 0.45),
            CameraKeyframe(time: 12.0, scale: 1.38, focusX: 0.61, focusY: 0.45),
            // Overview of economics breakdown
            CameraKeyframe(time: 14.30, scale: 1.30, focusX: 0.50, focusY: 0.65)
        ]),

        // Slide 8: Market Opportunity & TAM (14.00s + 0.50s pause = 14.50s)
        // "Forty million vendors represent an 18-billion-dollar demand" -> Card 1: $18 Billion Demand
        // "Scaling to 250,000 merchants across eight trading hubs" -> Card 2: 8 Trading Hubs
        // "unlocks 18 million dollars in annual recurring revenue" -> Card 3: $18M ARR
        SlideChoreography(slideIndex: 8, duration: 14.50, keyframes: [
            CameraKeyframe(time: 0.0, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 1.2, scale: 1.0, focusX: 0.50, focusY: 0.50),
            // Focus on Card 1: $18 Billion Demand
            CameraKeyframe(time: 3.0, scale: 1.35, focusX: 0.22, focusY: 0.58),
            CameraKeyframe(time: 5.5, scale: 1.35, focusX: 0.22, focusY: 0.58),
            // Pan to Card 2: 8 Trading Hubs (8 Cities)
            CameraKeyframe(time: 7.2, scale: 1.35, focusX: 0.50, focusY: 0.58),
            CameraKeyframe(time: 9.5, scale: 1.35, focusX: 0.50, focusY: 0.58),
            // Pan to Card 3: $18M ARR
            CameraKeyframe(time: 11.2, scale: 1.38, focusX: 0.78, focusY: 0.58),
            CameraKeyframe(time: 14.50, scale: 1.38, focusX: 0.78, focusY: 0.58)
        ]),

        // Slide 9: Scaled Implementation Roadmap (13.20s + 0.50s pause = 13.70s)
        // "pilots with 1,000 vendors in Delhi's Azadpur Mandi" -> Phase 1
        // "scales with Small Finance Banks" -> Phase 2
        // "expands nationally to 100,000 merchants across fifteen states" -> Phase 3
        SlideChoreography(slideIndex: 9, duration: 13.70, keyframes: [
            CameraKeyframe(time: 0.0, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 1.2, scale: 1.0, focusX: 0.50, focusY: 0.50),
            // Phase 1: Azadpur Mandi Pilot
            CameraKeyframe(time: 3.0, scale: 1.35, focusX: 0.22, focusY: 0.58),
            CameraKeyframe(time: 5.0, scale: 1.35, focusX: 0.22, focusY: 0.58),
            // Phase 2: Small Finance Banks via OCEN 4.0
            CameraKeyframe(time: 6.8, scale: 1.35, focusX: 0.50, focusY: 0.58),
            CameraKeyframe(time: 8.8, scale: 1.35, focusX: 0.50, focusY: 0.58),
            // Phase 3: National Scale 100,000 Merchants
            CameraKeyframe(time: 10.5, scale: 1.38, focusX: 0.78, focusY: 0.58),
            CameraKeyframe(time: 13.70, scale: 1.38, focusX: 0.78, focusY: 0.58)
        ]),

        // Slide 10: Conclusion & Dignity Restored (10.48s)
        // "FinFlow saves vendors over 7,500 rupees every month" -> Raju photo & Saves Over ₹7,500 Every Month
        // "restoring economic freedom and dignity to the backbone of our economy" -> Economic Freedom & Dignity
        SlideChoreography(slideIndex: 10, duration: 10.48, keyframes: [
            CameraKeyframe(time: 0.0, scale: 1.0, focusX: 0.50, focusY: 0.50),
            CameraKeyframe(time: 1.2, scale: 1.0, focusX: 0.50, focusY: 0.50),
            // Zoom to Raju portrait and Saves Over ₹7,500 Every Month badge
            CameraKeyframe(time: 3.5, scale: 1.32, focusX: 0.30, focusY: 0.55),
            CameraKeyframe(time: 6.0, scale: 1.32, focusX: 0.30, focusY: 0.55),
            // Gentle pan to reveal the 3 impact pillars
            CameraKeyframe(time: 8.0, scale: 1.20, focusX: 0.55, focusY: 0.55),
            CameraKeyframe(time: 10.48, scale: 1.15, focusX: 0.50, focusY: 0.50)
        ])
    ]

    let tempVideoUrl = URL(fileURLWithPath: "/tmp/finflow_motion_raw.mp4")
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

    print("🎬 Rendering Motion-Designed 1080p Video with Dynamic Camera Zooms...")

    for ch in choreography {
        let imagePath = "presentation/screenshots/slide_\(ch.slideIndex).png"
        guard let nsImage = NSImage(contentsOfFile: imagePath),
              let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Error loading image at \(imagePath)")
            continue
        }

        let numFrames = Int64(round(ch.duration * Double(fps)))
        print("  - Slide \(ch.slideIndex): Encoding \(numFrames) motion frames (\(ch.duration)s)...")

        for f in 0..<numFrames {
            while !writerInput.isReadyForMoreMediaData {
                usleep(1000)
            }

            let frameTimeInSlide = Double(f) / Double(fps)
            let camera = getCameraState(for: frameTimeInSlide, in: ch.keyframes)

            guard let buffer = createPixelBuffer(width: width, height: height) else { continue }
            renderFrame(
                cgImage: cgImage,
                scale: camera.scale,
                focusX: camera.x,
                focusY: camera.y,
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
        print("✅ Raw motion video writing completed!")
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
            print("\n🎉 SUCCESS: Motion-designed presentation video exported: FinFlow_Demo_Presentation.mp4")
        } else {
            print("\n❌ ERROR: Export failed: \(String(describing: exportSession.error))")
        }
        exportSemaphore.signal()
    }
    exportSemaphore.wait()
}

main()
