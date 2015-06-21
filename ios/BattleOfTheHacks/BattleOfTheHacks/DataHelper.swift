//
//  DataHelper.swift
//  BattleOfTheHacks
//
//  Created by Matt on 6/20/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON

class DataHelper {
  var data: JSON
  var lastLocationLoaded: CLLocation
  let distanceCutoff: Double = 50.0
  var hasLoaded: Bool
  var error: Bool
  
  init(location: CLLocation) {
    self.lastLocationLoaded = location
    self.data = JSON([])
    self.hasLoaded = false
    self.error = false
    loadData(location)
  }
  
  func loadData(location: CLLocation) {
    self.hasLoaded = false
    lastLocationLoaded = location
    let parameters: Dictionary<String,AnyObject> = ["lat": location.coordinate.latitude, "lon": location.coordinate.longitude]
    Alamofire.request(Method.GET, "http://b14s.schlosser.io/places", parameters: parameters)
      .responseJSON { (request, response, data, error) in
        let responseData = JSON(data!)
        self.error = (responseData["status"].string == "error")
        self.data = responseData
        self.hasLoaded = true
    }
  }
  
  func shouldUpdate(location: CLLocation) -> Bool {
    return location.distanceFromLocation(lastLocationLoaded) > distanceCutoff
  }
  
  func updateData(location: CLLocation) {
    if shouldUpdate(location) {
      lastLocationLoaded = location
      loadData(location)
    }
  }
  
  func numberOfItems() -> Int {
    return self.data["data"].count
  }
  
  func placeForBearing(bearing: CLHeading) -> JSON? {
    return hasLoaded && !error ? placeForKey(data["data"]["map"][Int(bearing.magneticHeading)].string!) : nil
  }
  
  func placeForKey(key: String) -> JSON? {
    return hasLoaded && !error ? data["data"]["data"][key] : nil
  }
}