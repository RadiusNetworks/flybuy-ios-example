//
//  orders.swift
//  FlyBuy Example
//
//  Copyright © 2020 Radius Networks. All rights reserved.
//

import Foundation
import FlyBuySDK

struct FoodOrder {
  let orderId: String
  let items: String
  let total: Double
  let created: Double
  var status: String
  var flyBuyOrder: Order?
  
  var statusDisplay: String {
    get {
      if let flyBuyOrder = flyBuyOrder {
        if flyBuyOrder.state == .completed  || flyBuyOrder.customerState == .completed {
          return "Completed"
        }
        else if flyBuyOrder.state == .cancelled {
          return "Cancelled"
        }
        else if flyBuyOrder.state == .delayed {
          return "Delayed"
        }
        else if flyBuyOrder.customerState == .arrived {
          return "Arrived"
        }
        else if flyBuyOrder.customerState == .waiting {
          return "Waiting"
        }
      }
      return status
    }
  }
  
  var createdDate: String {
    get {
      return dateForEpoch(epoch: created)
    }
  }
  
  var totalPrice: String {
    get {
      return formatTotalAsCurrency(total: total)
    }
  }
  
}

func statusForState(state: OrderState) -> String {
  switch state {
  case .cancelled: return "Cancelled"
  case .completed: return "Completed"
  case .created: return "Created"
  case .delayed: return "Delayed"
  case .gone: return "Gone"
  case .ready: return "Ready"
  default: return "Unknown"
  }
}

func formatTotalAsCurrency(total:Double) -> String {
  let formatter = NumberFormatter()
  formatter.locale = Locale.current
  formatter.numberStyle = .currency
  if let formattedTotal = formatter.string(from: total as NSNumber) {
    return formattedTotal
  }
  return "0.00"
}

func dateForEpoch(epoch:Double) -> String {
  let date = Date(timeIntervalSince1970: epoch)
  let dateFormatter = DateFormatter()
  dateFormatter.timeStyle = DateFormatter.Style.short
  dateFormatter.dateStyle = DateFormatter.Style.medium
  dateFormatter.timeZone = .current
  let localDate = dateFormatter.string(from: date)
  return localDate
}

func fetchOrders(completion: @escaping ([FoodOrder]) -> Void) {
  var fetchedOrders:[FoodOrder] = []

  FlyBuy.orders.fetch { (orders, error) -> (Void) in
    let flyBuyOrders = orders ?? []

  for flyBuyOrder in flyBuyOrders {
    if (flyBuyOrder.customerState != .completed) {
      let status = statusForState(state: flyBuyOrder.state)
   
      let order = FoodOrder(
        orderId: flyBuyOrder.partnerIdentifier ?? "",
        items: "",
        total: 0,
        created: 0,
        status: status,
        flyBuyOrder: flyBuyOrder)
    
      fetchedOrders.append(order)
    }
  }
            
  completion(fetchedOrders)
    return
  }
}

func createOrder(user:User, orderItems:[MenuItem], orderTotal:Double, completion: @escaping (Bool, String) -> Void) {
  let itemNames = orderItems.map { $0.title }
  let orderItems = itemNames.joined(separator: ", ")
  let _ = ["customerEmail": user.email, "orderItems": orderItems, "orderTotal": orderTotal] as [String : Any]
 
    // Create a FlyBuy customer info struct
    let customerInfo = CustomerInfo(name: user.name,
                                    carType: user.vehicleType,
                                    carColor: user.vehicleColor,
                                    licensePlate: user.licensePlate)

    let orderId = String(arc4random())
    let siteId = (FlyBuy.sites.all?.first?.id)!
    let pickupDateStart = Date()
    let pickupDateEnd = Date(timeIntervalSinceNow: 3600)
    let pickupWindow = PickupWindow(start: pickupDateStart, end: pickupDateEnd)

    FlyBuy.orders.create(siteID: siteId, partnerIdentifier: orderId, customerInfo: customerInfo, pickupWindow: pickupWindow) { (order, error) -> (Void) in
      completion(true, orderId)
      return
    }
}

func createOrderEvent(order: Order, customerState: CustomerState, completion: @escaping (Bool) -> Void) {
  FlyBuy.orders.event(orderID: order.id, customerState: customerState) { (order, error) in
    if let error = error {
      print(error)
    }
    completion(error == nil)
  }
}
