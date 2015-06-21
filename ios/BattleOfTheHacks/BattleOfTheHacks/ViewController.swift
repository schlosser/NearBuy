//
//  ViewController.swift
//  BattleOfTheHacks
//
//  Created by Matt on 6/20/15.

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
  
  let defaultLat: CGFloat = 37.4431
  let defaultLon: CGFloat = -122.1711
  let screenWidth = UIScreen.mainScreen().bounds.size.width
  let locationManager: CLLocationManager = CLLocationManager()

  let captureSession = AVCaptureSession()
  var previewLayer : AVCaptureVideoPreviewLayer?
  var captureDevice : AVCaptureDevice?

  override func viewDidLoad() {
    super.viewDidLoad()

    obtainDeviceAndBegin()
    configureCustomViews()
    configureLocationManager()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func configureCustomViews() {
    // Add custom subviews
    let sampleView:UIView = UIView(frame: CGRectMake(0, 0, screenWidth, 50))
    sampleView.backgroundColor = UIColor.redColor()
    self.view.addSubview(sampleView)
  }
  
  func configureLocationManager() {
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
  }
  
  func obtainDeviceAndBegin() {
    let devices = AVCaptureDevice.devices()
    for device in devices {
      if device.hasMediaType(AVMediaTypeVideo) {
        if device.position == AVCaptureDevicePosition.Back {
          captureDevice = device as? AVCaptureDevice
          if captureDevice != nil {
            beginSession(captureDevice!)
          }
        }
      }
    }
  }
    
  func beginSession(device: AVCaptureDevice) {
    configureDevice(device)
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
  
  func configureDevice(device: AVCaptureDevice) {
    device.lockForConfiguration(nil)
    device.focusMode = .Locked
    device.unlockForConfiguration()
  }

  func makePlacesCall(lat: CGFloat, lon: CGFloat) {
    Alamofire.request(Method.GET, "http://b14s.schlosser.io/places", parameters: ["lat": lat, "lon": lon])
      .responseJSON { (request, response, data, error) in
        let responseData = JSON(data!)
        println(responseData["data"]["lat"])
    }
  }
  
  // MARK: CLLocationManagerDelegate
  func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
    println("\(newLocation)")
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
    //println("\(newHeading.magneticHeading)")
  }
}
