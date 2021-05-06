//
//  TextExtractorVCViewModel.swift
//  VisionCreditScan
//
//  Created by Serhii Liamtsev on 5/6/21.
//  Copyright © 2021 Serhii Liamtsev. All rights reserved.
//

import Vision
import UIKit

protocol TextExtractorVCViewModelDelegate: AnyObject {
    
    func onTextRecognitionSuccess(_ text: String)
}

final class TextExtractorVCViewModel {
    
    weak var delegate: TextExtractorVCViewModelDelegate?
    
    let queue = OperationQueue()
    
    var lastPoint = CGPoint.zero
    
    var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
    private let textRecognitionWorkQueue = DispatchQueue(label: "MyVisionScannerQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    var scannedImage: UIImage
    
    init(scannedImage: UIImage) {
        self.scannedImage = scannedImage
    }
    
    func setupVision() {
        
        textRecognitionRequest = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var detectedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                
                
                detectedText += topCandidate.string
                detectedText += "\n"
            }
            
            self?.delegate?.onTextRecognitionSuccess(detectedText)
        }
        
        textRecognitionRequest.recognitionLevel = .accurate
    }
    
    func recognizeTextInImage(_ image: UIImage) {
        
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
    
}
