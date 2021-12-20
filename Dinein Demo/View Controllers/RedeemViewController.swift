//
//  SignInViewController.swift
//  FlyBuy Example
//
//  Copyright © 2020 Radius Networks. All rights reserved.
//

import UIKit
import FlyBuy

class RedeemViewController: UITableViewController {

  @IBOutlet weak var code: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func didPressCloseButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  func showErrorAlert() {
    let title = "Order not Found"
    let msg = "This order was not found. The order may have been redeeded already or the redemption code was incorrect"
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
      DispatchQueue.main.async {
        self.dismiss(animated: true, completion: nil)
      }
    }))
    DispatchQueue.main.async {
      self.present(alert, animated: true)
    }
  }
  
    func showRedeemAlert() {
      let title = "Order Redeemed"
      let msg = "This order had been redeemed and added to yout active orders"
      let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
        DispatchQueue.main.async {
          self.dismiss(animated: true, completion: nil)
        }
      }))
      DispatchQueue.main.async {
        self.present(alert, animated: true)
      }
    }
    
    @IBAction func didPressClaimButton(_ sender: Any) {
      let redemptionCode = code.text!
        let flybuyCustomer = FlyBuy.Core.customer.current

      if (flybuyCustomer != nil) {
        let customerInfo = flybuyCustomer?.info
        
        FlyBuy.Core.orders.claim(withRedemptionCode: redemptionCode, customerInfo: customerInfo!) { (order, error) -> (Void) in
          if (order == nil) {
            self.showErrorAlert()
          } else {
            FlyBuy.Core.orders.fetch()
            self.showRedeemAlert()
          }
        }
      } else {
        FlyBuy.Core.orders.fetch(withRedemptionCode: redemptionCode) { (order, error) -> (Void) in
          if (order == nil) {
            self.showErrorAlert()
          } else {
            FlyBuy.Core.orders.fetch()
            self.showRedeemAlert()
          }
        }
      }
    }
}
