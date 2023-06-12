
import UIKit
import Photos



public class MediaEditorManager {
    
    internal var type: AVFileType = .mov
    
    internal var exportPreset: String = AVAssetExportPresetHighestQuality
    
    internal var temporaryFolder: URL!
    
    internal var currctExportSession: AVAssetExportSession?
    
    public init() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("VideoEditor" + UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
            self.temporaryFolder = url
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

extension MediaEditorManager {
    ///支持mp4，mov
    public func changedAVType(type: AVFileType) {
        switch type {
        case .mp4:
            self.type = .mp4
        default:
            self.type = .mov
        }
    }
    
    public enum ExportPreset {
        case low
        case medium
        case highest
    }
    
    public func changedAVExportPreset(type: ExportPreset) {
        switch type {
        case .low:
            self.exportPreset = AVAssetExportPresetLowQuality
        case .medium:
            self.exportPreset = AVAssetExportPresetMediumQuality
        case .highest:
            self.exportPreset = AVAssetExportPresetHighestQuality
        }
    }
}


