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
  var links: Array<(String,String)>
  var currentPlace: NSString?
  
  init(location: CLLocation, completion: (() -> Void)? = nil) {
    self.lastLocationLoaded = location
    self.data = JSON([])
    self.hasLoaded = false
    self.error = false
    self.links = []
    loadData(location, completion: completion)
  }
  
  func loadData(location: CLLocation, completion: (() -> Void)? = nil) {
    self.hasLoaded = false
    lastLocationLoaded = location
    let parameters: Dictionary<String,AnyObject> = ["lat": location.coordinate.latitude, "lon": location.coordinate.longitude]
    Alamofire.request(Method.GET, "http://b14s.schlosser.io/places", parameters: parameters)
      .responseJSON { (request, response, data, error) in
        let responseData = JSON(data!)
        println("Finished data load")
        self.error = (responseData["status"].string == "error")
        self.data = responseData
        self.hasLoaded = true
        completion?()
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
    return links.count
  }
  
  func loadLinksForBearing(bearing: CLHeading) {
    self.currentPlace = keyForBearing(bearing)
    let place: JSON = placeForKey(self.currentPlace! as String)!
    println("Place: \(place)")
    for (index, object) in place["links"] {
      if index == "foursquare" {
        let foursquareLink: String = place["links"][index]["foursquareUrl"].stringValue
        links.append((index,foursquareLink))
      } else {
        let name = object.stringValue
        links.append((index,name))
      }
    }
  }
  
  func formatCellAtIndex(cell: UITableViewCell, index: NSIndexPath) {
    let link = self.links[(index.row)]
    if link.0 == "wikipediaUrl" {
      cell.textLabel!.text = "Research on Wikipedia"
      cell.imageView!.image = UIImage(named: "Wikipedia")
    } else if link.0 == "foursquare" {
      cell.textLabel!.text = "Read Reviews on Foursquare"
      cell.imageView!.image = UIImage(named: "Foursquare")
    } else {
      cell.textLabel!.text = "Something went wrong"
    }
  }
  
  func keyForBearing(bearing: CLHeading) -> NSString? {
    return data["data"]["map"][Int(bearing.magneticHeading)].string!
  }
  
  func placeForBearing(bearing: CLHeading) -> JSON? {
    return hasLoaded && !error ? placeForKey(data["data"]["map"][Int(bearing.magneticHeading)].string!) : nil
  }
  
  func placeForKey(key: String) -> JSON? {
    return hasLoaded && !error ? data["data"]["data"][key] : nil
  }
}