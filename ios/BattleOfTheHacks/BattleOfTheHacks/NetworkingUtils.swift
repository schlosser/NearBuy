//
//  NetworkingUtils.swift
//  BattleOfTheHacks
//
//  Created by Matt on 6/20/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

import Foundation
import CoreGraphics

struct URL {
  static let Base = "http://b14s.schlosser.io/"
  static let Places = Base + "places?"
}

func placesURL(lat: CGFloat, lon: CGFloat) -> NSString {
  return String(format: URL.Places + "lat=%f&lon=%f", arguments: [lat, lon])
}
