//
//  UpdateAccountViewController.swift
//  FlyBuy Example
//
//  Copyright © 2020 Radius Networks. All rights reserved.
//

import UIKit
import FlyBuySDK

class UpdateAccountViewController: UITableViewController {
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var emailAddress: UITextField!
  @IBOutlet weak var phone: UITextField!
  @IBOutlet weak var vehicleType: UITextField!
  @IBOutlet weak var vehicleColor: UITextField!
  @IBOutlet weak var licensePlate: UITextField!
  
  @IBAction func didPressCloseButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func didPressUpdateAccountButton(_ sender: Any) {
    let nm = name.text!
    let em = emailAddress.text!
    let ph = phone.text!
    let vt = vehicleType.text!
    let vc = vehicleColor.text!
    let lp = licensePlate.text!

    let customerInfo = CustomerInfo.init(name: nm, carType: vt, carColor: vc, licensePlate: lp, phone: ph)
    
    if (FlyBuy.customer.current != nil) {
      FlyBuy.customer.update(customerInfo)
    } else {
      FlyBuy.customer.create(customerInfo, termsOfService: true, ageVerification: true)
    }
    
    let fb = FlyBuy.customer.current?.token ?? ""
    let user = User(name: nm, email: em, phone: ph, vehicleType: vt, vehicleColor: vc, licensePlate: lp, flyBuyToken: fb)
    saveLocalUser(user: user)
    
    dismiss(animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    let flybuyCustomer = FlyBuy.customer.current
    
    if (flybuyCustomer != nil) {
        let info = flybuyCustomer?.info
        
        name.text = info?.name
        phone.text = info?.phone
        vehicleType.text = info?.carType
        vehicleColor.text = info?.carColor
        licensePlate.text = info?.licensePlate
    }
    super.viewDidLoad()
  }
  
}
