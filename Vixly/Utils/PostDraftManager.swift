import Foundation
import UIKit
import AVFoundation

class PostDraftManager {
    static let shared = PostDraftManager()
    
    private init() {}
    
    // MARK: - O-06 Post Creation State Machine
    // TODO: 实现完整的状态机，将以下四个步骤严格串起来，禁止跳过或回退超限
    enum Step: Int {
        case addMedia = 0        // AddMediaViewController
        case itemBreakdown = 1   // ItemBreakdownViewController
        case postDetails = 2     // PostDetailsViewController
        case reviewPublish = 3   // ReviewPublishViewController
        
        var title: String {
            switch self {
            case .addMedia: return "Add Media"
            case .itemBreakdown: return "Item Breakdown"
            case .postDetails: return "Post Details"
            case .reviewPublish: return "Review & Publish"
            }
        }
    }
    
    private(set) var currentStep: Step = .addMedia
    
    // TODO: 实现 validateStepTransition(from:to:) 校验，防止非法跳转
    func canTransition(to step: Step) -> Bool {
        // 允许前进、也允许回退到上一步编辑
        return abs(step.rawValue - currentStep.rawValue) <= 1
    }
    
    func transition(to step: Step) {
        guard canTransition(to: step) else { return }
        currentStep = step
    }
    
    var media: [PostMedia] = []
    var items: PostItems = PostItems(tops: [], bottoms: [], shoes: [], accessories: [])
    var caption: String = ""
    var styleTags: [String] = []
    var location: String = ""
    
    // TODO: 实现 validateDraft() -> Bool，在 ReviewPublish 前校验必填项
    var isDraftComplete: Bool {
        return hasMedia && hasCaption && hasStyleTags
    }
    
    func clear() {
        media = []
        items = PostItems(tops: [], bottoms: [], shoes: [], accessories: [])
        caption = ""
        styleTags = []
        location = ""
        currentStep = .addMedia
    }
    
    var hasMedia: Bool { !media.isEmpty }
    var hasCaption: Bool { !caption.isEmpty }
    var hasStyleTags: Bool { !styleTags.isEmpty }
}

enum PostMediaStorage {
    private static var mediaDirectory: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = base.appendingPathComponent("PostMedia", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    static func saveImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        let url = mediaDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
        do {
            try data.write(to: url, options: .atomic)
            return url.path
        } catch {
            return nil
        }
    }

    static func saveVideo(from sourceURL: URL) -> String? {
        let ext = sourceURL.pathExtension.isEmpty ? "mov" : sourceURL.pathExtension
        let destination = mediaDirectory.appendingPathComponent("\(UUID().uuidString).\(ext)")
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destination)
            return destination.path
        } catch {
            return nil
        }
    }

    static func saveAudio(from sourceURL: URL) -> String? {
        let destination = mediaDirectory.appendingPathComponent("\(UUID().uuidString).m4a")
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destination)
            return destination.path
        } catch {
            return nil
        }
    }
}

enum PostMediaPreview {
    static func image(for media: PostMedia) -> UIImage? {
        let assetNames = [media.url, (media.url as NSString).deletingPathExtension]
        for assetName in assetNames where !assetName.isEmpty {
            if let assetImage = UIImage(named: assetName) { return assetImage }
        }
        if media.type == .photo { return UIImage(contentsOfFile: media.url) }

        guard let mediaURL = url(for: media) else { return nil }
        let asset = AVURLAsset(url: mediaURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        guard let cgImage = try? generator.copyCGImage(at: CMTime(seconds: 0.05, preferredTimescale: 600), actualTime: nil) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    static func durationText(for media: PostMedia) -> String? {
        guard media.type == .video else { return nil }
        guard let mediaURL = url(for: media) else { return nil }
        let duration = AVURLAsset(url: mediaURL).duration.seconds
        guard duration.isFinite, duration > 0 else { return nil }
        let totalSeconds = Int(duration.rounded())
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    static func url(for media: PostMedia) -> URL? {
        if media.url.hasPrefix("/") {
            return URL(fileURLWithPath: media.url)
        }

        if let remoteURL = URL(string: media.url), remoteURL.scheme != nil {
            return remoteURL
        }

        let fileName = (media.url as NSString).lastPathComponent
        let pathExtension = (fileName as NSString).pathExtension
        let resourceName = pathExtension.isEmpty ? fileName : (fileName as NSString).deletingPathExtension
        let resourceExtension = pathExtension.isEmpty && media.type == .video ? "mp4" : pathExtension
        guard !resourceName.isEmpty, !resourceExtension.isEmpty else { return nil }

        if let bundledFile = Bundle.main.url(
            forResource: resourceName,
            withExtension: resourceExtension,
            subdirectory: media.type == .video ? "file" : nil
        ) {
            return bundledFile
        }

        return Bundle.main.url(forResource: resourceName, withExtension: resourceExtension)
    }
}
