//
//  Button.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/23/21.
//

import PopBounceButton

class Button: PopBounceButton {

  override init() {
    super.init()
    adjustsImageWhenHighlighted = false
    backgroundColor = .white
    layer.masksToBounds = true
  }

  required init?(coder aDecoder: NSCoder) {
    return nil
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    layer.cornerRadius = frame.width / 2
  }
}
