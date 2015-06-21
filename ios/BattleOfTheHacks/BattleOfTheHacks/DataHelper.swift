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
    /*
    if shouldUpdate(location) {
      lastLocationLoaded = location
      loadData(location)
    }
    */
  }
  
  func numberOfItems() -> Int {
    return links.count + 1
  }
  
  func loadLinksForBearing(bearing: CLHeading) {
    self.links = []
    self.currentPlace = keyForBearing(bearing)
    let place: JSON = placeForKey(self.currentPlace! as String)!
    println("Place: \(place)")
    for (index, object) in place["links"] {
      if index == "foursquare" {
        let venueId: String = place["links"][index]["foursquareVenueId"].stringValue
        let venueDeeplink = "foursquare://venues/" + venueId
        println("Venue Deep Link: \(venueDeeplink)")
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: venueDeeplink)!) {
          links.append((index,venueDeeplink))
        } else {
          let foursquareLink: String = place["links"][index]["foursquareUrl"].stringValue
          links.append((index,foursquareLink))
        }
      } else if index == "displayMetadata" {
        let rating: String = place["links"][index]["rating"].stringValue
        links.append((index,rating))
      } else {
        let name = object.stringValue
        links.append((index,name))
      }
    }
  }
  
  func formatCellAtIndex(cell: UITableViewCell, index: NSIndexPath) {
    if index.row < links.count {
      let link = self.links[(index.row)]
      if link.0 == "wikipediaUrl" {
        cell.textLabel!.text = "Research on Wikipedia"
        cell.imageView!.image = UIImage(named: "Wikipedia")
      } else if link.0 == "foursquare" {
        cell.textLabel!.text = "Read Reviews on Foursquare"
        cell.imageView!.image = UIImage(named: "Foursquare")
      } else if link.0 == "url" {
        cell.textLabel!.text = "View Website"
        cell.imageView!.image = UIImage(named: "Internet")
      } else if link.0 == "openTableUrl" {
        cell.textLabel!.text = "Make a Reservation on OpenTable"
        cell.imageView!.image = UIImage(named: "OpenTable")
      } else if link.0 == "displayMetadata" {
        cell.textLabel!.text = "Rating: \(link.1)"
        cell.imageView!.image = UIImage(named: "Rating")
      }
    } else {
      // This is our reminder!
      cell.textLabel!.text = "Create a Reminder"
      cell.imageView!.image = UIImage(named: "Reminders")
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
  
  func linkForIndex(index: NSIndexPath) -> String {
    return links[index.row].1
  }
}