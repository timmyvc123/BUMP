//
//  TinderCardContent.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/23/21.
//

import UIKit

class CardContentView: UIView {
    
    private var zoom: CGFloat = 0
    
    private let backgroundView: UIView = {
        let background = UIView()
        background.clipsToBounds = true
        background.layer.cornerRadius = 10
        return background
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.01).cgColor,
                           UIColor.black.withAlphaComponent(0.8).cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        return gradient
    }()
    
    init(withImage image: UIImage?) {
        super.init(frame: .zero)
        imageView.image = image
        initialize()
    }
    
    init(withImageView secondImageView: UIImageView?) {
        super.init(frame: .zero)
        imageView = secondImageView!
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func updateImagePosition() {
        zoom = min(zoom, 1)
        imageView.frame = bounds.applying(CGAffineTransform(scaleX: 1 + (1 - zoom), y: 1 + (1 - zoom)))
        imageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private func initialize() {
        addSubview(backgroundView)
        backgroundView.anchorToSuperview()
        backgroundView.addSubview(imageView)
        imageView.anchorToSuperview()
        applyShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2))
        backgroundView.layer.insertSublayer(gradientLayer, above: imageView.layer)
        updateImagePosition()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let heightFactor: CGFloat = 0.35
        gradientLayer.frame = CGRect(x: 0,
                                     y: (1 - heightFactor) * bounds.height,
                                     width: bounds.width,
                                     height: heightFactor * bounds.height)
    }
}

