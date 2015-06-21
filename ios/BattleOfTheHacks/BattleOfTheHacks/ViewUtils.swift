//
//  ViewUtils.swift
//  BattleOfTheHacks
//
//  Created by Matt on 6/20/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

import Foundation
import UIKit


func customImagePicker() -> UIImagePickerController {
  let imagePicker: UIImagePickerController = UIImagePickerController()
  imagePicker.sourceType = .Camera
  imagePicker.showsCameraControls = false
  imagePicker.cameraOverlayView?.backgroundColor = UIColor.redColor()
  let translate:CGAffineTransform = CGAffineTransformMakeTranslation(0.0, 71.0) //This slots the preview exactly in the middle of the screen by moving it down 71 points
  let scale:CGAffineTransform = CGAffineTransformScale(translate, 1.333333, 1.333333)
  imagePicker.cameraViewTransform = scale
  
  return imagePicker
}