//
//  TextExtractorVCView.swift
//  VisionCreditScan
//
//  Created by Serhii Liamtsev on 5/6/21.
//  Copyright © 2021 Serhii Liamtsev. All rights reserved.
//

import UIKit

protocol TextExtractorVCViewDelegate: AnyObject {
    
    func didTapBackButton()
    func didTapActionButton()
}

final class TextExtractorVCView: UIView {
    
    weak var delegate: TextExtractorVCViewDelegate?
    
    private(set) lazy var overlay = UIView()
    
    private(set) lazy var verticalContainerView: UIStackView = UIStackView()
    
    private let disclaimerLabel: UILabel = UILabel()
    
    private(set) lazy var imageView: UIImageView = UIImageView()
    
    private let buttonsContainer: UIStackView = UIStackView()
    
    private let backButton: UIButton = UIButton()
    private let buttonSize: CGFloat = UIScreen.height / 8
    private let buttonColor: UIColor = .white
    
    private let buttonBorderColor: UIColor = .black
    private let buttonBorderWidth: CGFloat = 3.0
    
    private let retryButton: UIButton = UIButton()
    private lazy var button: UIButton = UIButton(type: .system)
    
    private lazy var digitsLabel: UILabel = UILabel(frame: .zero)
    
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
    
    func setResultText(_ text: String?) {
        
        digitsLabel.text = text
    }
    
    func clearOverlay(){
        overlay.isHidden = false
        overlay.frame = CGRect.zero
    }
    
    func drawSelectionArea(fromPoint: CGPoint, toPoint: CGPoint) {
        
        let originX: CGFloat = min(fromPoint.x, toPoint.x)
        let originY: CGFloat = min(fromPoint.y, toPoint.y)
        
        let width: CGFloat = abs(fromPoint.x - toPoint.x)
        let height: CGFloat = abs(fromPoint.y - toPoint.y)
        let rect = CGRect(x: originX,
                          y: originY,
                          width: width,
                          height: height)
        overlay.frame = rect
    }
    
    func getOverlayedSnapshot() -> UIImage {
        
        return UIGraphicsImageRenderer(bounds: overlay.frame).image { _ in
            
            clearOverlay()
            imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
        }
    }
    
    // MARK: - Private functions
    private func initialSetup() {
        
        setupLayout()
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        button.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    private func setupLayout() {
        
        addSubview(verticalContainerView)
        verticalContainerView.isUserInteractionEnabled = true
        verticalContainerView.axis = .vertical
        verticalContainerView.spacing = 10
        verticalContainerView.alignment = .center
        
        verticalContainerView.translatesAutoresizingMaskIntoConstraints = false
        let verticalContainerViewConstraints: [NSLayoutConstraint] = [
            
            verticalContainerView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            verticalContainerView.bottomAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            verticalContainerView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            verticalContainerView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ]
        NSLayoutConstraint.activate(verticalContainerViewConstraints)
        
        verticalContainerView.addArrangedSubview(disclaimerLabel)
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.textAlignment = .center
        disclaimerLabel.text = "Please drag and select text area\nbefore extraction - try to touch and drag card image"
        
        verticalContainerView.addArrangedSubview(imageView)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        
        imageView.addSubview(overlay)
        imageView.bringSubviewToFront(overlay)
        overlay.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        overlay.isHidden = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let imageViewConstraints: [NSLayoutConstraint] = [
            imageView.leadingAnchor.constraint(equalTo: verticalContainerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: verticalContainerView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant:  UIScreen.main.bounds.height * 0.5)
        ]
        NSLayoutConstraint.activate(imageViewConstraints)
        
        verticalContainerView.addArrangedSubview(digitsLabel)
        digitsLabel.numberOfLines = 0
        digitsLabel.textAlignment = .center
        
        verticalContainerView.addArrangedSubview(buttonsContainer)
        buttonsContainer.axis = .horizontal
        buttonsContainer.spacing = UIScreen.main.bounds.width * 0.1
        buttonsContainer.alignment = .center
        
        buttonsContainer.addArrangedSubview(backButton)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(UIColor.systemBlue, for: .normal)
        backButton.backgroundColor = buttonColor
        backButton.layer.cornerRadius = buttonSize / 2
        backButton.layer.borderWidth = buttonBorderWidth
        backButton.layer.borderColor = buttonBorderColor.cgColor
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        let captureButtonConstraints: [NSLayoutConstraint] = [
            
            backButton.heightAnchor.constraint(equalToConstant: buttonSize),
            backButton.widthAnchor.constraint(equalToConstant: buttonSize)
        ]
        NSLayoutConstraint.activate(captureButtonConstraints)
        
        buttonsContainer.addArrangedSubview(button)
        button.setTitle("Extract Digits", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.backgroundColor = buttonColor
        button.layer.cornerRadius = buttonSize / 2
        button.layer.borderWidth = buttonBorderWidth
        button.layer.borderColor = buttonBorderColor.cgColor
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonConstraints: [NSLayoutConstraint] = [
            button.heightAnchor.constraint(equalToConstant: buttonSize),
            button.widthAnchor.constraint(equalToConstant: buttonSize)
        ]
        NSLayoutConstraint.activate(buttonConstraints)
        
    }
    
    // MARK: - Actions
    @objc
    func didTapActionButton(){
        
        delegate?.didTapActionButton()
    }
    
    @objc
    func didTapBackButton() {
        
        delegate?.didTapBackButton()
    }
    
}
