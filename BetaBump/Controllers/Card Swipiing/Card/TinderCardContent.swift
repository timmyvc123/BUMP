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
        imageView.contentMode = .scaleAspectFill
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
    
    @objc func soundButtonTapped() {
        print("sound button tapped")
    }
    
    private func initialize() {
        
//        let soundButton = UIButton(type: .custom)
//        soundButton.addTarget(self, action: #selector(soundButtonTapped), for: .touchUpInside)
//        if let image = UIImage(named: "fire") {
//            soundButton.setImage(image, for: .normal)
//            soundButton.imageView?.contentMode = .scaleAspectFit
////            soundButton.frame = CGRect(x: 100, y: 150, width: 37, height: 37)
//            soundButton.imageEdgeInsets = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
//        }
//        soundButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
//        soundButton.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
//        soundButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        soundButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
//        addSubview(soundButton)
////        soundButton.anchor(bottom: bottomAnchor, right: rightAnchor, paddingBottom: 60, paddingRight: 30)
//        UIWindow.key?.addSubview(soundButton)
        
        
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

//MARK: - Extensions

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
