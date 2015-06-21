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
  var leftArrow: UIImageView?
  var rightArrow: UIImageView?
  var dealsButton: UIButton?

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
    setupButtons()
    setupArrows()
  }
  
  func setupButtons() {
    placeName = UIButton(frame: CGRectMake(Views.Margin / 2.0, screenHeight - Views.ButtonHeight - Views.Margin, screenWidth - Views.Margin, Views.ButtonHeight))
    placeName!.layer.cornerRadius = 0.0
    placeName!.backgroundColor = Views.ButtonColor
    placeName!.setTitleColor(UIColor.blackColor(), forState: .Normal)
    placeName!.titleLabel!.font = Views.ButtonFont
    placeName!.addTarget(self, action: Selector("showPlaceDetails"), forControlEvents: UIControlEvents.TouchUpInside)
    placeName!.hidden = true
    self.view.addSubview(placeName!)
    
    dealsButton = UIButton(frame: CGRectMake(Views.Margin / 2.0, Views.Margin, screenWidth - Views.Margin, Views.ButtonHeight))
    dealsButton!.layer.cornerRadius = 0.0
    dealsButton!.backgroundColor = Views.ButtonColor
    dealsButton!.setTitle("Deals in your area", forState: .Normal)
    dealsButton!.setTitleColor(UIColor.blackColor(), forState: .Normal)
    dealsButton!.titleLabel!.font = Views.ButtonFont
    dealsButton!.addTarget(self, action: Selector("loadDeals"), forControlEvents: UIControlEvents.TouchUpInside)
    self.view.addSubview(dealsButton!)
  }
  
  func showPlaceDetails() {
    println("Show place!")
  }
  
  func loadDeals() {
    println("Load deals!")
  }
  
  func setupArrows() {
    leftArrow = UIImageView(frame: CGRectMake(Views.Margin / 2.0, (screenHeight / 2.0) - (Views.ArrowHeight / 2.0), Views.ArrowHeight, Views.ArrowHeight))
    leftArrow?.image = UIImage(named: "LeftArrow")
    view.addSubview(leftArrow!)
    
    rightArrow = UIImageView(frame: CGRectMake(screenWidth - (Views.Margin / 2.0) - Views.ArrowHeight, (screenHeight / 2.0) - (Views.ArrowHeight / 2.0), Views.ArrowHeight, Views.ArrowHeight))
    rightArrow?.image = UIImage(named: "RightArrow")
    view.addSubview(rightArrow!)
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
      if difference < General.DegreeMargin {
        let placeName: String = currentPlace["name"].string!
        self.placeName?.setTitle(placeName, forState: UIControlState.Normal)
        self.placeName?.hidden = false
      } else {
        self.placeName?.hidden = true
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
