//
//  OrderDetailsViewController.swift
//  FlyBuy Example
//
//  Copyright © 2020 Radius Networks. All rights reserved.
//

import FlyBuySDK
import UIKit

class OrderDetailsViewController: UIViewController {

  var order:FoodOrder?
  
  @IBOutlet weak var orderNumberLabel: UILabel!
  @IBOutlet weak var orderDetailsTextView: UITextView!
  @IBOutlet weak var onMyWayButton: BorderedButton!
  @IBOutlet weak var hereButton: BorderedButton!
  @IBOutlet weak var doneButton: BorderedButton!
  
  @IBOutlet weak var onMyWayButtonHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var hereButtonHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var doneButtonTopConstraint: NSLayoutConstraint!

  @IBAction func onMyWayButtonPressed(_ sender: Any) {
    if let foodOrder = order {
      if let flyBuyOrder = foodOrder.flyBuyOrder {
        createOrderEvent(order: flyBuyOrder, customerState: .enRoute) { (result) in
          if result == true {
            self.showAlert(title: "See you soon!", msg: "Your food will be ready on arrival.")
            self.toggleButtons(state: CustomerState.enRoute)
          }
          else {
            self.showAlert(title: "Uh-oh!", msg: "Something went wrong")
          }
        }
      }
    }
  }
    
  @IBAction func hereButtonPressed(_ sender: Any) {
    if let foodOrder = order {
      if let flyBuyOrder = foodOrder.flyBuyOrder {
        createOrderEvent(order: flyBuyOrder, customerState: .waiting) { (result) in
          if result == true {
            self.showAlert(title: "Thanks!", msg: "Your food should be out shortly.")
            self.toggleButtons(state: CustomerState.waiting)
          }
          else {
            self.showAlert(title: "Uh-oh!", msg: "Something went wrong")
          }
        }
      }
    }
  }
  
  @IBAction func doneButtonPressed(_ sender: Any) {
    if let foodOrder = order {
      if let flyBuyOrder = foodOrder.flyBuyOrder {
        createOrderEvent(order: flyBuyOrder, customerState: .completed) { (result) in
          if result == true {
            self.toggleButtons(state: CustomerState.completed)
            self.showOrderCompleteAlert(title: "Order Complete", msg: "Enjoy your food!")
          }
          else {
            self.showAlert(title: "Uh-oh!", msg: "Something went wrong")
          }
        }
      }
    }
  }
  
  func showOrderCompleteAlert(title: String, msg: String) {
    let alert = UIAlertController(title: "Order Complete", message: "Enjoy your food!", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
      self.navigationController?.popViewController(animated: true)
    }))

    DispatchQueue.main.async {
      self.present(alert, animated: true)
    }
  }
  
  func showAlert(title: String, msg: String) {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

    DispatchQueue.main.async {
      self.present(alert, animated: true)
    }
  }
  
  func toggleButtons(state: CustomerState) {
    DispatchQueue.main.async {
      if state == .enRoute {
        self.onMyWayButton.isHidden = true
        self.hereButton.isHidden = false
        self.doneButton.isHidden = true
        self.onMyWayButtonHeightConstraint.constant = 0
        self.hereButtonHeightConstraint.constant = 0
        self.doneButtonTopConstraint.constant = 0
      }
      if state == .waiting {
        self.onMyWayButton.isHidden = true
        self.hereButton.isHidden = true
        self.doneButton.isHidden = false
        self.hereButtonHeightConstraint.constant = 0
        self.doneButtonTopConstraint.constant = 0
      }
      else if state == .completed {
        self.onMyWayButton.isHidden = true
        self.hereButton.isHidden = true
        self.doneButton.isHidden = true
      }
      else {
        self.onMyWayButton.isHidden = false
        self.hereButton.isHidden = false
        self.hereButtonHeightConstraint.constant = 58
        self.doneButton.isHidden = true
      }
    }
  }
  
  func hideAllButtons() {
    self.onMyWayButton.isHidden = true
    self.hereButton.isHidden = true
    self.doneButton.isHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let order = self.order {
      orderDetailsTextView.text = orderDetailsText(order:order)
      orderNumberLabel.text = "Order #\(order.orderId)"
      
      if let flyBuyOrder = order.flyBuyOrder {
        if flyBuyOrder.state == .completed || flyBuyOrder.state == .cancelled || flyBuyOrder.customerState == .completed {
          hideAllButtons()
        }
        else {
          toggleButtons(state: flyBuyOrder.customerState)
        }
      }
    }
  }
  
  func orderDetailsText(order:FoodOrder) -> String {
    let orderDetails:String = "\(order.items)\n\n\(order.totalPrice)\n\nStatus: \(order.statusDisplay)"
    return orderDetails
  }

}
