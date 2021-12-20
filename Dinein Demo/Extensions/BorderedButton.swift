//
//  RoundedButton.swift
//  FlyBuy Example
//
//  Copyright © 2020 Radius Networks. All rights reserved.
//

import UIKit

@IBDesignable class BorderedButton: UIButton {
  
  @IBInspectable var borderWidth: CGFloat = 2 {
    didSet {
      refreshBorderWidth(value: borderWidth)
    }
  }
  
  @IBInspectable var borderColor: UIColor = .black {
    didSet {
      refreshBorderColor(value: borderColor)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    sharedInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    sharedInit()
  }
  
  override func prepareForInterfaceBuilder() {
    sharedInit()
  }
  
  func sharedInit() {
    // Common logic goes here
  }
  
  func refreshBorderWidth(value: CGFloat) {
    layer.borderWidth = value
  }

  func refreshBorderColor(value: UIColor) {
    layer.borderColor = value.cgColor
  }

}
