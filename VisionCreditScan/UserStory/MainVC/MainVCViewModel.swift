//
//  MainVCViewModel.swift
//  VisionCreditScan
//
//  Created by Serhii Liamtsev on 5/6/21.
//  Copyright © 2021 Serhii Liamtsev. All rights reserved.
//

import AVFoundation
import Vision
import UIKit

protocol MainVCViewModelDelegate: AnyObject {
    
    func createLayer(in rect: CGRect)
    func removeMask()
    
    func didCaptureCardImage(_ image: UIImage)
    
}

final class MainVCViewModel: NSObject {
    
    weak var delegate: MainVCViewModelDelegate?
    
    private let captureSession = AVCaptureSession()
    lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "camera_frame_processing_queue")
    
    var isUserTapped = false
    
    func changeCaptureSessionStatus(isOn: Bool) {
        
        switch isOn {
        case true:
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            captureSession.startRunning()
            
        case false:
            videoDataOutput.setSampleBufferDelegate(nil, queue: nil)
            captureSession.stopRunning()
        }
    }
    
    func setAVCaptureInput(_ input: AVCaptureDeviceInput) {
        
        captureSession.addInput(input)
    }
    
    func doPerspectiveCorrection(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) {
        
        var ciImage = CIImage(cvImageBuffer: buffer)
        
        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)
        
        // pass those to the filter to extract/rectify the image
        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight),
        ])
        
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let output = UIImage(cgImage: cgImage!)
        //UIImageWriteToSavedPhotosAlbum(output, nil, nil, nil)
        
        delegate?.didCaptureCardImage(output)
    }
    
    func setCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                mediaType: .video,
                position: .back).devices.first else {
            fatalError("No back camera device found.")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    
    func setCameraOutput() {
        
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        self.captureSession.addOutput(self.videoDataOutput)
        
        guard let connection = videoDataOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else { return
        }
        
        connection.videoOrientation = .portrait
    }
    
    private func detectRectangle(in image: CVPixelBuffer) {
        
        let request = VNDetectRectanglesRequest(completionHandler: { request, error in
            DispatchQueue.main.async {
                
                guard let results = request.results as? [VNRectangleObservation] else {
                    return
                }
                self.delegate?.removeMask()
                
                guard let rect = results.first else{
                    return
                }
                self.drawBoundingBox(rect: rect)
                
                if self.isUserTapped{
                    self.isUserTapped = false
                    self.doPerspectiveCorrection(rect, from: image)
                }
            }
        })
        
        request.minimumAspectRatio = VNAspectRatio(1.3)
        request.maximumAspectRatio = VNAspectRatio(1.6)
        request.minimumSize = Float(0.5)
        request.maximumObservations = 1
        
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? imageRequestHandler.perform([request])
    }
    
    func drawBoundingBox(rect: VNRectangleObservation) {
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.previewLayer.frame.height)
        let scale = CGAffineTransform.identity.scaledBy(x: self.previewLayer.frame.width, y: self.previewLayer.frame.height)
        
        let bounds = rect.boundingBox.applying(scale).applying(transform)
        delegate?.createLayer(in: bounds)
        
    }
    
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension MainVCViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("unable to get image from sample buffer")
            return
        }
        
        detectRectangle(in: frame)
    }
    
}
