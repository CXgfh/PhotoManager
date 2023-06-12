import Foundation
import AVFoundation

public class DeviceFeedbackManager: NSObject {
    ///震动反馈
    /*
     一般震动：kSystemSoundID_Vibrate
     普通短震（类似3D Touch的Peek反馈）：1519
     普通短震（类似3D Touch的Pop反馈）：1520
     连续3次短震：1521
     */
    public static func vibrationFeedback(soundID: SystemSoundID = kSystemSoundID_Vibrate) {
        AudioServicesPlayAlertSound(soundID)
    }
    
    ///声音反馈： scoure声音地址
    public static func voiceFeedback(scoure: URL) {
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(scoure as CFURL, &soundID)
        AudioServicesAddSystemSoundCompletion(soundID, nil, nil, { (soundID, rawPointer) in
            AudioServicesRemoveSystemSoundCompletion(soundID)
            AudioServicesDisposeSystemSoundID(soundID)
        }, nil)
        
        AudioServicesPlaySystemSound(soundID)
    }
    
    ///声音+震动反馈： scoure声音地址
    public static func voiceAndVibrationFeedback(scoure: URL, soundID: SystemSoundID = kSystemSoundID_Vibrate) {
        var id = soundID
        AudioServicesCreateSystemSoundID(scoure as CFURL, &id)
        
        AudioServicesAddSystemSoundCompletion(id, nil, nil, { (id, rawPointer) in
            AudioServicesRemoveSystemSoundCompletion(id)
            AudioServicesDisposeSystemSoundID(id)
        }, nil)
        
        AudioServicesPlayAlertSound(id)
    }
}
