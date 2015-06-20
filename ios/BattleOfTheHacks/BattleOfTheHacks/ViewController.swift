//
//  ViewController.swift
//  BattleOfTheHacks
//
//  Created by Matt on 6/20/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
  
  let defaultLat: CGFloat = 37.4431
  let defaultLon: CGFloat = -122.1711

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let queryString: NSString = placesURL(defaultLat, defaultLon)
    
    Alamofire.request(Method.GET, "http://b14s.schlosser.io/places", parameters: ["lat": defaultLat, "lon": defaultLon])
      .responseJSON { (request, response, data, error) in
        println(request)
        let responseData = JSON(data!)
        println(responseData)
        println(responseData["data"]["lat"])
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

