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
    
    private var maskLayer = [CAShapeLayer]()

    private let viewModel: TextExtractorVCViewModel
    
    private let contentView: TextExtractorVCView = TextExtractorVCView()
    
    // MARK: - Life cycle
    init(scannedImage: UIImage) {
        self.viewModel =  TextExtractorVCViewModel(scannedImage: scannedImage)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Init view controller programmaticaly, please")
    }
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.setupVision()
        viewModel.delegate = self
        setupUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        contentView.clearOverlay()
        if let touch = touches.first {
            lastPoint = touch.location(in: self.contentView.verticalContainerView)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: contentView.verticalContainerView)
            contentView.drawSelectionArea(fromPoint: lastPoint, toPoint: currentPoint)
        }
    }
    
    private func setupUI() {
        
        navigationItem.title = "Extract card number"
        view.backgroundColor = .black
        contentView.delegate = self
        contentView.imageView.image = viewModel.scannedImage
    }
    
}

// MARK: - TextExtractorVCViewDelegate
extension TextExtractorVC: TextExtractorVCViewDelegate {
    
    func didTapBackButton() {
        
        navigationController?.popViewController(animated: true)
    }
    
    func didTapActionButton() {
        
        let image: UIImage = contentView.getOverlayedSnapshot()
        viewModel.recognizeTextInImage(image)
    }
    
}

// MARK: - TextExtractorVCViewModelDelegate
extension TextExtractorVC: TextExtractorVCViewModelDelegate {
    
    func onTextRecognitionSuccess(_ text: String) {
        
        DispatchQueue.main.async{
            self.contentView.setResultText(text)
        }
    }
    
}
