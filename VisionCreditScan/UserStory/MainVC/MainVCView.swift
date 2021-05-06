//
//  MainVCView.swift
//  VisionCreditScan
//
//  Created by Serhii Liamtsev on 5/6/21.
//  Copyright © 2021 iowncode. All rights reserved.
//

import UIKit

protocol MainVCViewDelegate: AnyObject {
    
    func didTapCaptureButton()
}

final class MainVCView: UIView {
    
    weak var delegate: MainVCViewDelegate?
    
    private let captureButton: UIButton = UIButton()
    private let captureButtonSize: CGFloat = UIScreen.height / 10
    private let captureButtonColor: UIColor = .white
    
    private let captureButtonBorderColor: UIColor = .black
    private let captureButtonBorderWidth: CGFloat = 3.0
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    private func initialSetup() {
        
        setupLayout()
        captureButton.addTarget(self, action: #selector(didTapCaptureButton), for: .touchUpInside)
    }
    
    private func setupLayout() {
        
        addSubview(captureButton)
        captureButton.setTitle("Scan", for: .normal)
        captureButton.setTitleColor(UIColor.systemBlue, for: .normal)
        captureButton.backgroundColor = captureButtonColor
        captureButton.layer.cornerRadius = captureButtonSize / 2
        captureButton.layer.borderWidth = captureButtonBorderWidth
        captureButton.layer.borderColor = captureButtonBorderColor.cgColor
        
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        let captureButtonConstraints: [NSLayoutConstraint] = [
            
            captureButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            captureButton.heightAnchor.constraint(equalToConstant: captureButtonSize),
            captureButton.widthAnchor.constraint(equalToConstant: captureButtonSize)
        ]
        NSLayoutConstraint.activate(captureButtonConstraints)
        
    }
    
    // MARK: - Actions
    @objc
    private func didTapCaptureButton() {
        
        delegate?.didTapCaptureButton()
    }
    
}
