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

class ViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

  let screenWidth = UIScreen.mainScreen().bounds.size.width
  let screenHeight = UIScreen.mainScreen().bounds.size.height
  let locationManager: CLLocationManager = CLLocationManager()
  var locationButton: UIButton?

  let captureSession = AVCaptureSession()
  var previewLayer : AVCaptureVideoPreviewLayer?
  var captureDevice : AVCaptureDevice?
  var dataHelper: DataHelper?
  var pictureTimer: NSTimer!
  var stillImageOutput: AVCaptureStillImageOutput = AVCaptureStillImageOutput()
  var placeName: UIButton?

  override func viewDidLoad() {
    super.viewDidLoad()

    obtainDeviceAndBegin()
    configureCustomViews()
    configureLocationManager()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    // Start Registering Pictures
    pictureTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("capturePhoto"), userInfo: nil, repeats: true)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func configureCustomViews() {
    setupButton()
  }
  
  func setupButton() {
    placeName = UIButton(frame: CGRectMake(Views.Margin / 2, screenHeight - Views.ButtonHeight - Views.Margin, screenWidth - Views.Margin, Views.ButtonHeight))
    placeName!.layer.cornerRadius = 0.0
    placeName!.backgroundColor = Views.ButtonColor
    placeName!.setTitle("Default Text", forState: .Normal)
    self.view.addSubview(placeName!)
  }
  
  func configureLocationManager() {
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
  }
  
  // MARK: AVFoundation
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
    captureSession.addOutput(self.stillImageOutput)
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
  
  func capturePhoto() {
    self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)) { (buffer:CMSampleBuffer!, error:NSError!) -> Void in
      var image = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
      var dataImage = UIImage(data: image)
    }
  }
  
  // MARK: CLLocationManagerDelegate
  func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
    if dataHelper == nil {
      dataHelper = DataHelper(location: newLocation)
    } else {
      dataHelper?.updateData(newLocation)
    }
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
    handleCurrentBearing(newHeading)
  }
  
  func handleCurrentBearing(bearing: CLHeading) {
    if let currentPlace: JSON = dataHelper!.placeForBearing(bearing) {
      let difference = abs(currentPlace["bearing"].doubleValue - bearing.magneticHeading)
      println("Difference: \(difference)")
      if difference < General.DegreeMargin {
        let placeName: String = currentPlace["name"].string!
        self.placeName?.setTitle(placeName, forState: UIControlState.Normal)
        self.placeName?.hidden = false
      } else {
        self.placeName?.setTitle("DEFAULT", forState: UIControlState.Normal)
        self.placeName?.hidden = false
      }
    }
  }
  
  // MARK: UICollectionViewDelegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    // TODO: We need to select things.
  }
  
  // MARK: UICollectionViewDataSource
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = UICollectionViewCell()
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.dataHelper!.numberOfItems()
  }
}
