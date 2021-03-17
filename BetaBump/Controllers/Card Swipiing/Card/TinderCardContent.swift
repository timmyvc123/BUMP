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
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var imageURL: URL?
    
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
    
    init(withImageURL imageURL: URL?) {
        super.init(frame: .zero)
        let getDataTask = URLSession.shared.dataTask(with: imageURL!) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let coverImage = UIImage(data: data)
                self.imageView.image = coverImage
            }
        }
        getDataTask.resume()
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
    
    func fetchImage(imageURL: URL?) {
        // get data
        // convert the data to image
        // set image to imageview
        
        let getDataTask = URLSession.shared.dataTask(with: imageURL!) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                CardContentView.init(withImage: image)
            }
        }
        getDataTask.resume()
    }
    
}
