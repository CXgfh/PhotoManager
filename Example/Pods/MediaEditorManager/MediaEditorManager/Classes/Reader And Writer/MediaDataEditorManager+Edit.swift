//
//  MediaEditorManager+Edit.swift
//  MediaEditorManager
//
//  Created by Vick on 2022/10/9.
//

import Foundation
import AVKit

//MARK: - 视频编辑

extension MediaDataEditorManager {
    public func edit(at asset: AVAsset,
                     tailoring: MediaEditorTailoring?,
                     angle: MediaEditorAngle = .degrees0,
                     compression: MediaEditorCompression?,
                     waterMakers: [MediaEditorWaterMaker]?,
                     progress: ((_ value: Double)->())? = nil,
                     complete: @escaping (_ result: MediaEditorResult)->()) {
        
        var range: CMTimeRange
        if let tailoring = tailoring {
            let start = CMTimeMakeWithSeconds(Double(tailoring.star)*asset.duration.seconds, preferredTimescale: asset.duration.timescale)
            let end = CMTimeMakeWithSeconds(Double(tailoring.end)*asset.duration.seconds, preferredTimescale: asset.duration.timescale)
            range = CMTimeRange(start: start, end: end)
        } else {
            range = CMTimeRange(start: .zero, duration: asset.duration)
        }
        
        edit(at: asset, range: range, angle: angle, compression: compression, waterMakers: waterMakers, progress: progress, complete: complete)
    }
    
    public func edit(at asset: AVAsset,
                     range: CMTimeRange,
                     angle: MediaEditorAngle,
                     compression: MediaEditorCompression?,
                     waterMakers: [MediaEditorWaterMaker]?,
                     progress: ((_ value: Double)->())? = nil,
                     complete: @escaping (_ result: MediaEditorResult)->()) {
        guard writeAudioCompleted, writeVideoCompleted else {
            complete(.failure(MediaEditorError.hadTaskInProgress))
            return
        }
        
        let url = self.temporaryFolder.appendingPathComponent(UUID().uuidString+type.suffix)
        writeAudioCompleted = false
        writeVideoCompleted = false
        timeRange = range
        
        if initReader(asset: asset,
                      angle: angle,
                      waterMakers: waterMakers,
                      audioMix: compression?.audioMix),
            initWriter(url: url,
                       videoSettings: compression?.videoSettings,
                       audioSettings: compression?.audioSettings) {
            startRecording(progress) { result in
                switch result {
                case .success(_):
                    complete(.success(url))
                case .failure(let error):
                    complete(.failure(error))
                }
            }
        } else {
            complete(.failure(MediaEditorError.initReaderOrWriter))
        }
    }
    
    private func initReader(asset: AVAsset,
                            angle: MediaEditorAngle,
                            waterMakers: [MediaEditorWaterMaker]?,
                            audioMix: AVAudioMix?) -> Bool {
        do {
            reader = try AVAssetReader(asset: asset)
            reader.timeRange = timeRange
            
            let videoTracks = asset.tracks(withMediaType: .video)
            videoOutput = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks, videoSettings: nil)
            videoOutput.alwaysCopiesSampleData = alwaysCopiesSampleData
            videoOutput.videoComposition = videoComposition(tracks: videoTracks, angle: angle, waterMakers: waterMakers, time: timeRange)
            
            if reader.canAdd(videoOutput) {
                reader.add(videoOutput)
            }
            
            let audioTracks = asset.tracks(withMediaType: .audio)
            audioOutput = AVAssetReaderAudioMixOutput(audioTracks: audioTracks, audioSettings: nil)
            audioOutput.alwaysCopiesSampleData = alwaysCopiesSampleData
            audioOutput.audioMix = audioMix

            if reader.canAdd(audioOutput) {
                reader.add(audioOutput)
            }
            return true
        } catch {
            debugPrint(error)
            return false
        }
    }
    
    private func initWriter(url: URL,
                            videoSettings: [String: Any]?,
                            audioSettings: [String: Any]?) -> Bool {
        do {
            writer = try AVAssetWriter(url: url, fileType: type)
            writer.shouldOptimizeForNetworkUse = self.shouldOptimizeForNetworkUse
            
            videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            videoInput.expectsMediaDataInRealTime = expectsMediaDataInRealTime
            if writer.canAdd(videoInput) {
                writer.add(videoInput)
            }
            
            audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            audioInput.expectsMediaDataInRealTime = false
            if writer.canAdd(audioInput) {
                writer.add(audioInput)
            }
            return true
        } catch {
            debugPrint(error)
            return false
        }
    }
    
    private func startRecording(_ progress: ((_ value: Double)->())?,
                                _ complete: @escaping (_ result: MediaEditorResult) -> Void) {
        if writer.startWriting(), reader.startReading() {
            writer.startSession(atSourceTime: timeRange.start)
            videoInput.requestMediaDataWhenReady(on: inputQueue) { //开启了很多串行任务
                self.encodeReadySamplesFromOutput(output: self.videoOutput, input: self.videoInput, progress)
                self.finsh(complete)
            }
    
            audioInput.requestMediaDataWhenReady(on: inputQueue) {
                self.encodeReadySamplesFromOutput(output: self.audioOutput, input: self.audioInput, progress)
                self.finsh(complete)
            }
        } else {
            complete(.failure(MediaEditorError.startReaderOrWriting))
        }
    }
    
    private func encodeReadySamplesFromOutput(output: AVAssetReaderOutput,
                                              input: AVAssetWriterInput,
                                              _ progress: ((_ value: Double)->())?) {
        while input.isReadyForMoreMediaData {
            if let sampleBuffer = output.copyNextSampleBuffer() {
                if output == videoOutput {
                    let current = timeRange.duration.seconds == 0 ? 1 : CMTimeGetSeconds(CMTimeSubtract(CMSampleBufferGetPresentationTimeStamp(sampleBuffer), timeRange.start)) / timeRange.duration.seconds
                    progress?(current)
                    input.append(sampleBuffer)
                } else {
                    input.append(sampleBuffer)
                }
            } else {
                input.markAsFinished()
                if input == videoInput {
                    progress?(1)
                    writeVideoCompleted = true
                } else {
                    writeAudioCompleted = true
                }
            }
        }
    }
    
    private func finsh(_ complete: @escaping (_ result: MediaEditorResult) -> Void) {
        if writeAudioCompleted, writeVideoCompleted {
            if reader.status == .cancelled
                || writer.status == .cancelled {
                complete(.failure(MediaEditorError.cancel))
            } else if writer.status == .failed
                        || reader.status == .failed {
                self.writer.cancelWriting()
                complete(.failure(MediaEditorError.failedReadingOrWriting))
            } else {
                if writeAudioCompleted, writeVideoCompleted {
                    writer.finishWriting {
                        complete(.success(nil))
                    }
                }
            }
        }
    }
}

