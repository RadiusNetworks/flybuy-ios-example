//
//  UserManager.swift
//  FlyBuy Example
//
//  Copyright © 2020 Radius Networks. All rights reserved.
//

import Foundation

struct User {
  let name: String
  let email: String
  let phone: String
  let vehicleType: String
  let vehicleColor: String
  let licensePlate: String
  let flyBuyToken: String
}

func loadLocalUser() -> User {
  let ph = UserDefaults.standard.string(forKey: "phone") ?? ""
  let em = UserDefaults.standard.string(forKey: "email") ?? ""
  let nm = UserDefaults.standard.string(forKey: "name") ?? ""
  let vt = UserDefaults.standard.string(forKey: "vehicleType") ?? ""
  let vc = UserDefaults.standard.string(forKey: "vehicleColor") ?? ""
  let lp = UserDefaults.standard.string(forKey: "licensePlate") ?? ""
  let fb = UserDefaults.standard.string(forKey: "flyBuyToken") ?? ""
    
  let user = User(name: nm, email: em, phone: ph, vehicleType: vt, vehicleColor: vc, licensePlate: lp, flyBuyToken: fb)
  return user
}

func saveLocalUser(user:User) {
  UserDefaults.standard.set(user.phone, forKey: "phone")
  UserDefaults.standard.set(user.email, forKey: "email")
  UserDefaults.standard.set(user.name, forKey: "name")
  UserDefaults.standard.set(user.vehicleType, forKey: "vehicleType")
  UserDefaults.standard.set(user.vehicleColor, forKey: "vehicleColor")
  UserDefaults.standard.set(user.licensePlate, forKey: "licensePlate")
  UserDefaults.standard.set(user.flyBuyToken, forKey: "flyBuyToken")
}

func deleteLocalUser() {
  UserDefaults.standard.removeObject(forKey: "phone")
  UserDefaults.standard.removeObject(forKey: "email")
  UserDefaults.standard.removeObject(forKey: "name")
  UserDefaults.standard.removeObject(forKey: "vehicleType")
  UserDefaults.standard.removeObject(forKey: "vehicleColor")
  UserDefaults.standard.removeObject(forKey: "licensePlate")
  UserDefaults.standard.removeObject(forKey: "flyBuyToken")
}

func signOut(completion: (Bool) -> Void) {
  deleteLocalUser()
  completion(true)
}

func isSignedIn() -> Bool {
  let localUser = loadLocalUser()
  return localUser.phone.count > 0
}
