//
//  RadiusSliderView.swift
//  GeoFencing
//
//  Created by Sameed Ansari on 18/03/2025.
//

import UIKit

protocol RadiusSliderDelegate: AnyObject {
    func radiusDidChange(radius: Double)
}

class RadiusSliderView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: RadiusSliderDelegate?
    private(set) var currentRadius: Double = 100.0
    
    private let minRadius: Double = 100.0
    private let maxRadius: Double = 1000.0
    
    private let sliderTrackHeight: CGFloat = 10.0
    private let thumbSize: CGFloat = 26.0
    
    private let radiusLabel = UILabel()
    private let trackView = UIView()
    private let thumbView = UIView()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        trackView.backgroundColor = .systemGray5
        trackView.layer.cornerRadius = sliderTrackHeight / 2
        addSubview(trackView)
        
        thumbView.backgroundColor = .systemBlue
        thumbView.layer.cornerRadius = thumbSize / 2
        thumbView.layer.shadowColor = UIColor.black.cgColor
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 2)
        thumbView.layer.shadowOpacity = 0.3
        thumbView.layer.shadowRadius = 3
        addSubview(thumbView)
        
        radiusLabel.textAlignment = .center
        radiusLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        radiusLabel.text = "\(Int(currentRadius)) m"
        addSubview(radiusLabel)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        thumbView.addGestureRecognizer(panGesture)
        thumbView.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackView.frame = CGRect(
            x: thumbSize / 2,
            y: (bounds.height - sliderTrackHeight) / 2,
            width: bounds.width - thumbSize,
            height: sliderTrackHeight
        )
        
        radiusLabel.frame = CGRect(
            x: 0,
            y: trackView.frame.origin.y - 30,
            width: bounds.width,
            height: 20
        )
        
        updateThumbPosition(animated: false)
    }
    
    // MARK: - User Interaction
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: self)
        let trackWidth = bounds.width - thumbSize
        
        var xPosition = min(max(touchPoint.x, thumbSize / 2), trackWidth + thumbSize / 2) - thumbSize / 2
        
        let percentage = xPosition / trackWidth
        let newRadius = minRadius + (maxRadius - minRadius) * Double(percentage)
        
        setRadius(newRadius)
    }
    
    // MARK: - Public Methods
    
    func setRadius(_ radius: Double, animated: Bool = true) {
        currentRadius = min(max(radius, minRadius), maxRadius)
        
        radiusLabel.text = "\(Int(currentRadius)) m"
        updateThumbPosition(animated: animated)
        
        delegate?.radiusDidChange(radius: currentRadius)
    }
    
    // MARK: - Helper Methods
    
    private func updateThumbPosition(animated: Bool) {
        let percentage = (currentRadius - minRadius) / (maxRadius - minRadius)
        let trackWidth = bounds.width - thumbSize
        let xPosition = CGFloat(percentage) * trackWidth
        
        let newFrame = CGRect(
            x: xPosition,
            y: (bounds.height - thumbSize) / 2,
            width: thumbSize,
            height: thumbSize
        )
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.thumbView.frame = newFrame
            }
        } else {
            thumbView.frame = newFrame
        }
    }
} 
