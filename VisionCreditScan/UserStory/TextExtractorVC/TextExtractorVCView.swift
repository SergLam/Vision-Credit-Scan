//
//  TextExtractorVCView.swift
//  VisionCreditScan
//
//  Created by Serhii Liamtsev on 5/6/21.
//  Copyright © 2021 iowncode. All rights reserved.
//

import UIKit

protocol TextExtractorVCViewDelegate: AnyObject {
    
    func didTapActionButton()
}

final class TextExtractorVCView: UIView {
    
    weak var delegate: TextExtractorVCViewDelegate?
    
    private(set) lazy var overlay = UIView()
    
    private let verticalContainerView: UIStackView = UIStackView()
    
    private let disclaimerLabel: UILabel = UILabel()
    
    private(set) lazy var imageView: UIImageView = UIImageView()
    
    private let retryButton: UIButton = UIButton()
    private(set) lazy var button: UIButton = UIButton(type: .system)
    
    private(set) lazy var digitsLabel: UILabel = UILabel(frame: .zero)
    
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
    
    func clearOverlay(){
        overlay.isHidden = false
        overlay.frame = CGRect.zero
    }
    
    func setOverlayFrame(_ frame: CGRect) {
        overlay.frame = frame
    }
    
    private func initialSetup() {
        
        setupLayout()
        
        button.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    private func setupLayout() {
        
        imageView.contentMode = .scaleAspectFit
        
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
//        addSubview(disclaimerLabel)
//        disclaimerLabel.numberOfLines = 0
//        disclaimerLabel.textAlignment = .center
//        disclaimerLabel.text = "Please drag and select text area before extraction - try to touch and drag card image"
//
//        disclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
//        let disclaimerLabelConstraints: [NSLayoutConstraint] = [
//            disclaimerLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
//            disclaimerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
//            disclaimerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
//        ]
//        NSLayoutConstraint.activate(disclaimerLabelConstraints)
        
        button.setTitle("Extract Digits", for: .normal)
        addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(digitsLabel)
        digitsLabel.numberOfLines = 0
        digitsLabel.textAlignment = .center
        
        digitsLabel.translatesAutoresizingMaskIntoConstraints = false
        digitsLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        digitsLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        digitsLabel.bottomAnchor.constraint(equalTo: self.button.topAnchor, constant: -20).isActive = true
        digitsLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        overlay.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        overlay.isHidden = true
        
        imageView.addSubview(overlay)
        imageView.bringSubviewToFront(overlay)
    }
    
    // MARK: - Actions
    @objc
    func didTapActionButton(){
        
        delegate?.didTapActionButton()
    }
    
}
