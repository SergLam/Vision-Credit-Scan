//
//  ViewController.swift
//  VisionCreditScan
//
//  Created by Serhii Liamtsev on 27/01/20.
//  Copyright © 2020 VisionCreditScan. All rights reserved.
//


import UIKit
import AVFoundation
import Vision

final class MainVC: UIViewController {
    
    private let viewModel: MainVCViewModel = MainVCViewModel()
    
    private let contentView: MainVCView = MainVCView()
    
    private var maskLayer = CAShapeLayer()
    
    // MARK: - Life cycle
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.delegate = self
        viewModel.delegate = self
        viewModel.setCameraInput()
        showCameraFeed()
        viewModel.setCameraOutput()
        
        navigationItem.title = "Scan bank card"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.changeCaptureSessionStatus(isOn: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.changeCaptureSessionStatus(isOn: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size: CGSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.8)
        self.viewModel.previewLayer.frame = CGRect(origin: self.view.frame.origin, size: size)
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
        
        let secondVC = TextExtractorVC(scannedImage: output)
        navigationController?.pushViewController(secondVC, animated: false)
        
    }
    
    private func setCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                mediaType: .video,
                position: .back).devices.first else {
            fatalError("No back camera device found.")
        }
        
        do {
            
            let cameraInput = try AVCaptureDeviceInput(device: device)
            viewModel.setAVCaptureInput(cameraInput)
            
        } catch {
            
            assertionFailure("Unable to get input from capture device - \(error.localizedDescription)")
        }
        
    }
    
    private func showCameraFeed() {
        viewModel.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(viewModel.previewLayer)
        viewModel.previewLayer.frame = self.view.frame
    }
    
}

// MARK: - MainVCViewDelegate
extension MainVC: MainVCViewDelegate {
    
    func didTapCaptureButton() {
        viewModel.isUserTapped = true
    }
    
}

// MARK: - MainVCViewModelDelegate
extension MainVC: MainVCViewModelDelegate {
    
    func createLayer(in rect: CGRect) {
        
        maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.cornerRadius = 10
        maskLayer.opacity = 0.75
        maskLayer.borderColor = UIColor.red.cgColor
        maskLayer.borderWidth = 5.0
        
        viewModel.previewLayer.insertSublayer(maskLayer, at: 1)
    }
    
    func removeMask() {
        maskLayer.removeFromSuperlayer()
    }
    
    func didCaptureCardImage(_ image: UIImage) {
        
        let secondVC = TextExtractorVC(scannedImage: image)
        self.navigationController?.pushViewController(secondVC, animated: false)
    }
    
}
