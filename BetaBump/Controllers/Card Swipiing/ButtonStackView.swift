//
//  ButtonStackView.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/23/21.
//

import PopBounceButton

protocol ButtonStackViewDelegate: AnyObject {
  func didTapButton(button: Button)
}

class ButtonStackView: UIStackView {

  weak var delegate: ButtonStackViewDelegate?

  private let undoButton: Button = {
    let button = Button()
    button.setImage(UIImage(named: "undo"), for: .normal)
    button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    button.tag = 1
    return button
  }()

  private let passButton: Button = {
    let button = Button()
    button.setImage(UIImage(named: "pass"), for: .normal)
    button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    button.tag = 2
    return button
  }()

  private let superLikeButton: Button = {
    let button = Button()
    button.setImage(UIImage(named: "star"), for: .normal)
    button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    button.tag = 3
    return button
  }()

  private let likeButton: Button = {
    let button = Button()
    button.setImage(UIImage(named: "heart"), for: .normal)
    button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    button.tag = 4
    return button
  }()

  private let boostButton: Button = {
    let button = Button()
    button.setImage(UIImage(named: "lightning"), for: .normal)
    button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    button.tag = 5
    return button
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    distribution = .equalSpacing
    alignment = .center
    configureButtons()
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureButtons() {
    let largeMultiplier: CGFloat = 66 / 414 //based on width of iPhone 8+
    let smallMultiplier: CGFloat = 54 / 414 //based on width of iPhone 8+
    addArrangedSubview(from: undoButton, diameterMultiplier: smallMultiplier)
    addArrangedSubview(from: passButton, diameterMultiplier: largeMultiplier)
    addArrangedSubview(from: superLikeButton, diameterMultiplier: smallMultiplier)
    addArrangedSubview(from: likeButton, diameterMultiplier: largeMultiplier)
    addArrangedSubview(from: boostButton, diameterMultiplier: smallMultiplier)
  }

  private func addArrangedSubview(from button: Button, diameterMultiplier: CGFloat) {
    let container = ButtonContainer()
    container.addSubview(button)
    button.anchorToSuperview()
    addArrangedSubview(container)
    container.translatesAutoresizingMaskIntoConstraints = false
    container.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: diameterMultiplier).isActive = true
    container.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
  }

  @objc
  private func handleTap(_ button: Button) {
    delegate?.didTapButton(button: button)
  }
}

private class ButtonContainer: UIView {

  override func draw(_ rect: CGRect) {
    applyShadow(radius: 0.2 * bounds.width, opacity: 0.05, offset: CGSize(width: 0, height: 0.15 * bounds.width))
  }
}

