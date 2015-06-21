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
  let distanceCutoff: Double = 1.0
  
  init(location: CLLocation) {
    self.lastLocationLoaded = location
    self.data = JSON([])
    loadData(location)
  }
  
  func loadData(location: CLLocation) {
    lastLocationLoaded = location
    let parameters: Dictionary<String,AnyObject> = ["lat": location.coordinate.latitude, "lon": location.coordinate.longitude]
    Alamofire.request(Method.GET, "http://b14s.schlosser.io/places", parameters: parameters)
      .responseJSON { (request, response, data, error) in
        let responseData = JSON(data!)
        self.data = responseData
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
}