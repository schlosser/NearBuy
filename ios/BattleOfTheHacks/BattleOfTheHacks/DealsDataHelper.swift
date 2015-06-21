//
//  DealsDataHelper.swift
//  BattleOfTheHacks
//
//  Created by Matt on 6/21/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON

class DealsDataHelper {
  var data: JSON
  var lastLocationLoaded: CLLocation
  let distanceCutoff: Double = 50.0
  var hasLoaded: Bool
  var error: Bool
  var links: Array<JSON>
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
    Alamofire.request(Method.GET, "http://b14s.schlosser.io/deals", parameters: parameters)
      .responseJSON { (request, response, data, error) in
        let responseData = JSON(data!)
        println("Finished deals data load")
        println("\(responseData)")
        self.links = responseData["data"].arrayValue
        self.error = (responseData["status"].string == "error")
        self.data = responseData
        self.hasLoaded = true
        completion?()
    }
  }
  
  func formatCellAtIndex(cell: UITableViewCell, index: NSIndexPath) {
    let deal: JSON = links[index.row]
    cell.textLabel!.text = deal["title"].stringValue
    cell.imageView!.image = UIImage(named: "Deal")
  }
  
  func alertViewForDeal(index: NSIndexPath) -> UIAlertController {
    let deal: JSON = links[index.row]
    let title: String = deal["title"].stringValue
    let body: String = deal["body"].stringValue
    let offerCode: String = deal["offer_code"].stringValue
    let alertBody = "\(body) Redeem your offer using code \(offerCode)"
    println("Alert Body: \(alertBody)")
    let alert: UIAlertController = UIAlertController(title: title, message: alertBody, preferredStyle: UIAlertControllerStyle.Alert)
    let defaultAction: UIAlertAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil)
    alert.addAction(defaultAction)
    return alert
  }
  
  func shouldUpdate(location: CLLocation) -> Bool {
    return location.distanceFromLocation(lastLocationLoaded) > distanceCutoff
  }
  
  func numberOfItems() -> Int {
    return links.count
  }

  func updateData(location: CLLocation) {
    /*
    if shouldUpdate(location) {
    lastLocationLoaded = location
    loadData(location)
    }
    */
  }
}