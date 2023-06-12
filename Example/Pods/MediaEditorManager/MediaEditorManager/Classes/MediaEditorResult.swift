//
//  MediaEditorError.swift
//  MediaEditorManager
//
//  Created by V on 2023/5/19.
//

import UIKit

public typealias MediaEditorResult = Result<URL?, Error>

public enum MediaEditorError: Error {
    case getVideoTrack
    case getAudioTrack
    case creatEmptyTrack
    case insetTrack
    case exportSession
    case exportError
    case aotatingURL
    case cancel
    case unowned
    case hadTaskInProgress
    
    case initReaderOrWriter
    case startReaderOrWriting
    case failedReadingOrWriting
}

extension MediaEditorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .getVideoTrack:
            return "获取视频轨道对象失败"
        case .getAudioTrack:
            return "获取音频轨道对象失败"
        case .creatEmptyTrack:
            return "‘新媒体’创建视频轨道失败"
        case .insetTrack:
            return "‘新媒体’插入媒体资源失败"
        case .exportSession:
            return "创建输出实例失败"
        case .exportError:
            return "视频输出失败"
        case .aotatingURL:
            return "旋转后的资源路径获取失败"
        case .cancel:
            return "用户取消"
        case .unowned:
            return "未知错误"
        case .hadTaskInProgress:
            return "当前有任务进行中，请等待任务完成或取消当前任务"
        case .startReaderOrWriting:
            return "开启读写任务失败"
        case .failedReadingOrWriting:
            return "读写任务失败"
        case .initReaderOrWriter:
            return "创建读写器失败"
        }
    }
}


