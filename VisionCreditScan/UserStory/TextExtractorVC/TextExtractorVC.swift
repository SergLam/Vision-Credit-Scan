//
//  TextExtractorVC.swift
//  VisionCreditScan
//
//  Created by Serhii Liamtsev on 27/01/20.
//  Copyright © 2020 VisionCreditScan. All rights reserved.
//

import UIKit
import Vision

final class TextExtractorVC: UIViewController {
    
    let queue = OperationQueue()
    
    var lastPoint = CGPoint.zero
    
    var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
    private let textRecognitionWorkQueue = DispatchQueue(label: "MyVisionScannerQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    var scannedImage: UIImage?
    
    private var maskLayer = [CAShapeLayer]()

    
    private let contentView: TextExtractorVCView = TextExtractorVCView()
    
    // MARK: - Life cycle
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVision()
        self.view.backgroundColor = .black
        contentView.delegate = self
        contentView.imageView.image = scannedImage
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        clearOverlay()
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawSelectionArea(fromPoint: lastPoint, toPoint: currentPoint)
        }
    }
    
    private func setupVision() {
        textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var detectedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                
                
                detectedText += topCandidate.string
                detectedText += "\n"
            }
            
            DispatchQueue.main.async{
                self.contentView.digitsLabel.text = detectedText
            }
        }
        
        textRecognitionRequest.recognitionLevel = .accurate
    }
    
    private func recognizeTextInImage(_ image: UIImage) {
        
        guard let cgImage = image.cgImage else {
            return
        }
        
        textRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
    
    func clearOverlay(){
        contentView.overlay.isHidden = false
        contentView.overlay.frame = CGRect.zero
    }
    
    func drawSelectionArea(fromPoint: CGPoint, toPoint: CGPoint) {
        
        let rect = CGRect(x: min(fromPoint.x, toPoint.x), y: min(fromPoint.y, toPoint.y), width: abs(fromPoint.x - toPoint.x), height: abs(fromPoint.y - toPoint.y))
        contentView.overlay.frame = rect
    }
    
    func snapshot(in imageView: UIImageView, rect: CGRect) -> UIImage {
        
        return UIGraphicsImageRenderer(bounds: rect).image { _ in
            
            clearOverlay()
            imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
        }
    }
    
}

// MARK: - TextExtractorVCViewDelegate
extension TextExtractorVC: TextExtractorVCViewDelegate {
    
    func didTapActionButton() {
        
        let image: UIImage = snapshot(in: contentView.imageView, rect: contentView.overlay.frame)
        recognizeTextInImage(image)
    }
    
}
