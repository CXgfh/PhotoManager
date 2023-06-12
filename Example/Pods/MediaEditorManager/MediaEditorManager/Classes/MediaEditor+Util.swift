//
//  Util.swift
//  MediaEditorManager
//
//  Created by V on 2023/2/26.
//

import UIKit
import AVFoundation

///视频角度
func videoAngle(_ track: AVAssetTrack) -> Int {
    var angle = 0
    let t = track.preferredTransform
    if t.a == 0, t.b == 1.0, t.c == -1.0, t.d == 0 {
        angle = 90
    } else if t.a == 0, t.b == -1.0, t.c == 1.0, t.d == 0 {
        angle = 270
    } else if t.a == 1.0, t.b == 0.0, t.c == 0, t.d == 1.0 {
        angle = 0
    } else if t.a == -1.0,  t.b == 0, t.c == 0, t.d == -1.0 {
        angle = 180
    } else if t.a == 1.0, t.b == 0, t.c == 0, t.d == -1.0 {
        angle = -180
    }
    return angle
}

///视频校正信息
func videoCorrectingMessage(_ track: AVAssetTrack, angle: Int) -> RotationMessage {
    let size = track.naturalSize
    let reverseSize = CGSize(width: size.height, height: size.width)
    switch angle {
    case 90:
        return RotationMessage(transform: CGAffineTransform(translationX: size.height, y: 0.0).rotated(by: .pi/2), size: reverseSize)
    case 180:
        return RotationMessage(transform: CGAffineTransform(translationX: size.width, y: size.height).rotated(by: .pi), size: size)
    case 270:
        return RotationMessage(transform: CGAffineTransform(translationX: 0.0, y: size.width).rotated(by: .pi*3/2), size: reverseSize)
    case -180:
        return RotationMessage(transform: CGAffineTransform(scaleX: 1.0, y: -1.0).scaledBy(x: 0, y: -size.height), size: size)
    default:
        return RotationMessage(transform: track.preferredTransform, size: size)
    }
}

func videoComposition(tracks: [AVAssetTrack],
                      angle: MediaEditorAngle,
                      waterMakers: [MediaEditorWaterMaker]?,
                      time: CMTimeRange) -> AVMutableVideoComposition {
    var size = CGSize.zero
    var layerInstructions =  [AVMutableVideoCompositionLayerInstruction]()
    for track in tracks {
        let message = videoCorrectingMessage(track, angle: angle.rawValue)
        
        if size.width < message.size.width {
            size.width = message.size.width
        }
        if size.height < message.size.height {
            size.height = message.size.height
        }
        
        //媒体图层指令对象
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        layerinstruction.setTransform(message.transform, at: track.timeRange.start)
        layerInstructions.append(layerinstruction)
    }
    
    //媒体指令对象
    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = time
    instruction.layerInstructions = layerInstructions
    
    //媒体合成对象
    let layerComposition = AVMutableVideoComposition()
    layerComposition.frameDuration = tracks.first!.minFrameDuration
    //renderSize 设置输出画板大小，内容从左上角开始绘制，小了则被裁剪，大了则黑边
    layerComposition.renderSize = size
    layerComposition.instructions = [instruction]
    
    //动画指令
    if let waterMakers = waterMakers {
        let animationTool = waterMakerAnimationTool(waterMakers: waterMakers, size: size)
        layerComposition.animationTool = animationTool
    }
    
    return layerComposition
}


func waterMakerAnimationTool(waterMakers: [MediaEditorWaterMaker], size: CGSize) -> AVVideoCompositionCoreAnimationTool {
    
    //父层
    let parentlayer = CALayer()
    parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
    //视频层
    let videolayer = CALayer()
    videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    parentlayer.addSublayer(videolayer)
    
    //水印层
    for maker in waterMakers {
        let imglayer = CALayer()
        if let imglogo = maker.image,
            let imageSize = maker.image?.size {
            imglayer.contents = imglogo.cgImage
            let watermarkFrame = CGRect(x: (size.width/2-imageSize.width/2.0)+maker.centerOffsetX,
                                        y: (size.height/2-imageSize.height/2.0)-maker.centerOffsetY,
                                        width: imageSize.width,
                                        height: imageSize.height)
            imglayer.frame = watermarkFrame
            imglayer.opacity = 0
            for animation in maker.animations {
                imglayer.add(animation, forKey: nil)
            }
        }
        parentlayer.addSublayer(imglayer)
    }
    
    return AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
}
