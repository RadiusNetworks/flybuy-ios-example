//
//  WelcomeViewController.swift
//  FlyBuy Example
//
//  Copyright © 2020 Radius Networks. All rights reserved.
//

import UIKit
import FlyBuy

class WelcomeViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if isSignedIn() {
      let localUser = loadLocalUser()
      print("Local User FlyBuy Token:", localUser.flyBuyToken)
    } else {
        print("No local user")
    }
  }
    
}
