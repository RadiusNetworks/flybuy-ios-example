//
//  ViewController.swift
//  FlyBuy Example
//
//  Copyright © 2020 Radius Networks. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

  @IBOutlet weak var claimOrder: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func didPressCloseButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
    
  @IBAction func claimOrderPressed(_ sender: Any) {
    signOut { (result) in
      dismiss(animated: false, completion: nil)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "createOrderSegue" {
      if let destinationNavigationController = segue.destination as? UINavigationController {
        if let targetController = destinationNavigationController.topViewController as? OrdersViewController {
          targetController.shouldCreateOrder = true
        }
      }
    }
  }
  
}

