//
//  MenuViewController.swift
//  FlyBuy Example
//
//  Copyright © 2020 Radius Networks. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

  let menuItems:[MenuItem] = [
    MenuItem(id:"item0", title:"Deli Sandwitch", price:4.99),
    MenuItem(id:"item1", title:"Clasic Cheese Burger", price:5.49),
    MenuItem(id:"item2", title:"Fries and a Shake", price:3.99),
  ]
  
  var cartItems:[MenuItem] = []
  var cartTotal:Double = 0.0
  
  @IBOutlet weak var cartLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    cartItems = []
    refreshCartLabel()
  }
  
  @IBAction func didPressCloseButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func didPressDoneButton(_ sender: Any) {
    let localUser = loadLocalUser()
    
    createOrder(user: localUser, orderItems: cartItems, orderTotal: cartTotal) { (result, orderNumber) in
      if (result == true) {
        self.showSuccessAlert(orderNumber: orderNumber)
          print(self.cartTotal)
      }
    }
  }
  
  func showSuccessAlert(orderNumber: String) {
    let title = "Order Created"
    let msg = "Your order number is \(orderNumber). You can find it on the \"my orders\" page."
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
  
  @IBAction func didPressAddButton(_ sender: UIButton) {
    didAddItemToCart(itemNumber: sender.tag)
  }
  
  func formatTotalAsCurrency(total:Double) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    formatter.numberStyle = .currency
    if let formattedTotal = formatter.string(from: total as NSNumber) {
      return formattedTotal
    }
    return "1.00"
  }
  
  func refreshCartLabel() {
    if cartItems.count == 0 {
      cartLabel.isHidden = true
    }
    else {
      let formattedTotal = formatTotalAsCurrency(total: cartTotal)
      let newLabelText = "There are \(cartItems.count) item(s) in your cart. Total: \(formattedTotal)"
      cartLabel.text = newLabelText
      cartLabel.isHidden = false
    }
  }
  
  func didAddItemToCart(itemNumber: Int) {
    let addedItem = menuItems[itemNumber]
    cartItems.append(addedItem)
    cartTotal = cartTotal + addedItem.price
    refreshCartLabel()
  }
  
}
