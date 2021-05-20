//
//  OrdersViewController.swift
//  FlyBuy Example
//
//  Copyright © 2020 Radius Networks. All rights reserved.
//

import UIKit

class OrdersViewController: UITableViewController {

  var shouldCreateOrder:Bool = false
  var orders:[FoodOrder] = []
  
  @IBAction func didPressCloseButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.refreshControl?.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if shouldCreateOrder {
      performSegue(withIdentifier: "createOrder", sender: self)
      shouldCreateOrder = false
    }
    else {
      fetchTableData()
    }
  }

  func fetchTableData() {
    fetchOrders() { (fetchedOrders) in
      DispatchQueue.main.async {
        self.refreshControl?.endRefreshing()
        self.orders = fetchedOrders
        self.tableView.reloadData()
      }
    }
  }
  
  @IBAction @objc func refreshTable(_ sender: Any) {
    print("need to refresh")
    fetchTableData()
  }
  
  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.orders.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72.0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath)
    let order = orders[indexPath.row]
    cell.textLabel?.text = "Order #\(order.orderId), \(order.totalPrice)"
    cell.detailTextLabel?.text = "Created \(order.createdDate)"
    return cell
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "orderDetailsSegue" {
      if let destinationViewController = segue.destination as? OrderDetailsViewController {
        if let indexPath = tableView.indexPathForSelectedRow {
          let order = orders[indexPath.row]
          destinationViewController.order = order
        }
      }
    }
  }
  
}
