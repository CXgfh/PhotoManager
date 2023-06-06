import UIKit
import Util_V
import AVFoundation
import SnapKit

/* 找设备对应的摄像头
 builtInWideAngleCamera 广角
 builtInUltraWideCamera 短焦
 builtInTelephotoCamera 长焦
 builtInDualCamera 广角和长焦
 builtInDualWideCamera 两个固定焦距、一个超广角和一个广角
 builtInTripleCamera 三个固定焦距、一个超广角、一个广角和一个长焦
 */

class CustomCameraViewController: UIViewController {
    
    weak var delegate: PhotoManagerDelegate?
    
    // Writer
    private lazy var writer: CustomCaptureWriter = {
        let writer = CustomCaptureWriter(session: captureSession)
        writer.delegate = self
        return writer
    }()
    
    // Session
    private lazy var captureSession = CustomCaptureSession()
    
    // 预览图层
    private lazy var preview = CustomCaptruePreview(session: captureSession.session)
    
    //MARK: ---- View -----
    private lazy var toolView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.addArrangedSubviews(switchbutton, camerabutton, flashlightbutton)
        return stack
    }()
    
    private lazy var camerabutton: UIButton = {
        let button = UIButton()
        if PhotoManager.sharde.cameraType == .video {
            button.setTitle("开始录像", for: .normal)
        } else {
            button.setImage(UIImage(photo: "picker_camera.circle.fill"), for: .normal)
        }
        button.addTarget(self, action: #selector(cameraTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var flashlightbutton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(photo: "picker_flashlight.on.fill"), for: .normal)
        button.addTarget(self, action: #selector(flashlightTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var switchbutton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(photo: "picker_arrow.triangle.2.circlepath.camera.fill"), for: .normal)
        button.addTarget(self, action: #selector(switchTap), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startCapture()
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        //AVCaptureDeviceWasConnectedNotification, AVCaptureDeviceWasDisconnectedNotification
    }
    
    deinit {
//        NotificationCenter.default.removeObserver(self)
        captureSession.stopCapture()
    }
}

extension CustomCameraViewController {
    @objc private func cameraTap() {
        switch PhotoManager.sharde.cameraType {
        case .shooting, .continuousShooting:
            writer.beganTakeImage = true
        case .video:
            if writer.beganTakeVideo {
                writer.beganTakeVideo = false
                camerabutton.setTitle("开始录像", for: .normal)
                writer.endRecording()
            } else {
                writer.beganTakeVideo = true
                camerabutton.setTitle("停止录像", for: .normal)
                writer.startRecording()
            }
        }
    }
    
    @objc private func flashlightTap() {
        captureSession.changeTorchMode()
    }
    
    @objc private func switchTap() {
        if captureSession.position == .back {
            captureSession.position = .front
        } else {
            captureSession.position = .back
        }
    }
}

extension CustomCameraViewController {
    private func setupUI() {
        preview.previewLayer.frame = view.frame
        view.layer.addSublayer(preview.previewLayer)
        
        view.addSubview(toolView)
        toolView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
}

extension CustomCameraViewController {
    private func startCapture() {
        captureSession.setInputs()
        writer.setup()
        captureSession.starCapture()
    }
    
    private func stopCapture() {
        captureSession.stopCapture()
    }
}

extension CustomCameraViewController: CustomCaptureWriterDelegate {
    func customCaptureWriterImage(image: UIImage) {
        if PhotoManager.sharde.allowsEditing,
            PhotoManager.sharde.cameraType == .shooting {
            let vc = EditImageViewController(image: image)
            vc.confirm = { new in
                self.dismiss(animated: true) {
                    PhotoManager.sharde.delegate.call {
                        $0.photoManagerEditResult?(image: new)
                    }
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            PhotoManager.sharde.delegate.call {
                $0.photoManagerCrameResult?(image: image)
            }
            switch PhotoManager.sharde.cameraType {
            case .shooting:
                self.dismiss(animated: true)
            default:
                self.captureSession.starCapture()
            }
        }
    }
    
    func customCaptureWriterVideo(url: URL) {
        if PhotoManager.sharde.allowsEditing {
            let vc = EditVideoViewController(url: url)
            vc.confirm = { new in
                self.dismiss(animated: true) {
                    PhotoManager.sharde.delegate.call {
                        $0.photoManagerEditResult?(video: new)
                    }
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.dismiss(animated: true) {
                PhotoManager.sharde.delegate.call {
                    $0.photoManagerCrameResult?(video: url, width: self.captureSession.videoWidth, height: self.captureSession.videoHeight)
                }
            }
        }
    }
}

/*
 CMSampleBufferInvalidate 通过调用示例缓冲区的失效回调使其失效
 */
