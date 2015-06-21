//
//  ViewController.swift
//  BattleOfTheHacks
//
//  Created by Matt on 6/20/15.

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class ViewController: UIViewController {
  
  let defaultLat: CGFloat = 37.4431
  let defaultLon: CGFloat = -122.1711
  let screenWidth = UIScreen.mainScreen().bounds.size.width

  let captureSession = AVCaptureSession()
  var previewLayer : AVCaptureVideoPreviewLayer?
  var captureDevice : AVCaptureDevice?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let devices = AVCaptureDevice.devices()

    for device in devices {
      if device.hasMediaType(AVMediaTypeVideo) {
        if device.position == AVCaptureDevicePosition.Back {
          captureDevice = device as? AVCaptureDevice
          if captureDevice != nil {
            beginSession()
          }
        }
      }
    }
    
    let sampleView:UIView = UIView(frame: CGRectMake(0, 0, screenWidth, 50))
    sampleView.backgroundColor = UIColor.redColor()
    
    self.view.addSubview(sampleView)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func configureDevice() {
    if let device = captureDevice {
      device.lockForConfiguration(nil)
      device.focusMode = .Locked
      device.unlockForConfiguration()
    }
  }
    
  func beginSession() {
    configureDevice()
    var error : NSError? = nil
    captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &error))
    if error != nil {
      println("Error: \(error?.localizedDescription)")
    }

    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    self.view.layer.addSublayer(previewLayer)
    previewLayer?.frame = self.view.layer.frame
    captureSession.startRunning()
  }

  func makePlacesCall(lat: CGFloat, lon: CGFloat) {
    Alamofire.request(Method.GET, "http://b14s.schlosser.io/places", parameters: ["lat": lat, "lon": lon])
      .responseJSON { (request, response, data, error) in
        let responseData = JSON(data!)
        println(responseData["data"]["lat"])
    }
  }
}
