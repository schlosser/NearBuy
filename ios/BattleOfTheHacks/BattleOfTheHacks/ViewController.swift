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
import EventKit

enum TableMode {
  case Deals
  case Options
}

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {

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
  var tableView: UITableView!
  var currentMode: TableMode?
  var overlay: UIView!
  var backButton: UIButton!
  

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBarHidden = true
    obtainDeviceAndBegin()
    configureCustomViews()
    configureLocationManager()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.navigationBarHidden = true
  }
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    // Start Registering Pictures
    // pictureTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("capturePhoto"), userInfo: nil, repeats: true)
    
    setupTableView()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func configureCustomViews() {
    setupButtons()
    setupArrows()
    setupOverlay()
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
    
    // Configure Back Button
    backButton = UIButton(frame: CGRectMake((screenWidth / 2.0) - (Views.BackButtonDimen / 2.0), screenHeight - (Views.Margin / 2.0) - (Views.BackButtonDimen), Views.BackButtonDimen, Views.BackButtonDimen))
    backButton.setImage(UIImage(named: "XButton"), forState: UIControlState.Normal)
    backButton.setImage(UIImage(named: "XButton"), forState: UIControlState.Selected)
    backButton.addTarget(self, action: Selector("backButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
    backButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
    
    addButtons()
  }
  
  func addButtons() {
    self.view.addSubview(placeName!)
    self.view.addSubview(dealsButton!)
  }
  
  func setupTableView() {
    let tableViewWidth = screenWidth - Views.Margin
    let tableViewHeight = screenHeight - (Views.Margin * 4.0) - (Views.ButtonHeight * 2.0)
    let rect: CGRect = CGRectMake(Views.Margin / 2.0, Views.Margin * 2.0 + Views.ButtonHeight, screenWidth - Views.Margin, tableViewHeight)
    tableView = UITableView(frame: rect)
    tableView!.delegate = self
    tableView!.dataSource = self
    tableView!.backgroundColor = UIColor.whiteColor()
    tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
  }
  
  func showPlaceDetails() {
    currentMode = TableMode.Options
    dataHelper?.loadLinksForBearing(self.locationManager.heading)
    addModal()
  }
  
  func loadDeals() {
    currentMode = TableMode.Deals
    addModal()
  }
  
  func addModal() {
    self.view.addSubview(overlay)
    tableView.hidden = false
    tableView.reloadData()
    self.view.addSubview(tableView)
    self.view.bringSubviewToFront(tableView)
    self.view.addSubview(backButton)
    self.view.bringSubviewToFront(backButton)
  }
  
  func backButtonPressed() {
    view.subviews.map({ $0.removeFromSuperview() })
    addButtons()
  }
  
  func setupOverlay() {
    overlay = UIView(frame: self.view.frame)
    overlay.backgroundColor = Views.ButtonColor
  }
  
  func setupArrows() {
    leftArrow = UIImageView(frame: CGRectMake(Views.Margin / 2.0, (screenHeight / 2.0) - (Views.ArrowHeight / 2.0), Views.ArrowHeight, Views.ArrowHeight))
    leftArrow?.image = UIImage(named: "LeftArrow")
    leftArrow?.backgroundColor = Views.ButtonColor
    leftArrow?.hidden = true
    view.addSubview(leftArrow!)
    
    rightArrow = UIImageView(frame: CGRectMake(screenWidth - (Views.Margin / 2.0) - Views.ArrowHeight, (screenHeight / 2.0) - (Views.ArrowHeight / 2.0), Views.ArrowHeight, Views.ArrowHeight))
    rightArrow?.image = UIImage(named: "RightArrow")
    rightArrow?.backgroundColor = Views.ButtonColor
    rightArrow?.hidden = true
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
      self.view.addSubview(overlay)
      let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
      activityIndicator.center = self.view.center
      activityIndicator.startAnimating()
      self.view.addSubview(activityIndicator)
      let mockLocation = CLLocation(latitude: 40.80591, longitude: -73.965559)
      dataHelper = DataHelper(location: mockLocation) {
        self.overlay.removeFromSuperview()
        activityIndicator.removeFromSuperview()
      }
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
        self.placeName?.hidden = true
      }
    }
  }
  
  // MARK: UITableViewDelegate, UITableViewDataSource
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if currentMode == TableMode.Deals {
      return 4
    } else if currentMode == TableMode.Options {
      return dataHelper!.numberOfItems()
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 75.0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath) as! UITableViewCell
    formatCell(cell, indexPath: indexPath)
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if indexPath.row + 1 < dataHelper?.numberOfItems() {
      let str: NSString = (dataHelper!.linkForIndex(indexPath) as NSString)
      let link: NSString = str.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
      let url: NSURL = NSURL(string: link as String)!
      // TODO: Check for deep links.'
      if UIApplication.sharedApplication().canOpenURL(url) && url.scheme != "http" && url.scheme != "https" {
        UIApplication.sharedApplication().openURL(url)
      } else {
        let viewController: UIViewController = UIViewController()
        let webView: UIWebView = UIWebView(frame: self.view.frame)
        webView.delegate = self
        viewController.view = webView
        webView.loadRequest(NSURLRequest(URL: url))
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.pushViewController(viewController, animated: true)
      }
    } else {
      // Our reminder cell
      var eventStore = EKEventStore()
      
      eventStore.requestAccessToEntityType(EKEntityTypeReminder,
        completion: {(granted: Bool, error:NSError!) in
          if !granted {
            println("Access to store not granted")
          } else {
            let reminder = EKReminder(eventStore: eventStore)
            reminder.title = "Go to the store and buy milk"
            reminder.calendar = eventStore.defaultCalendarForNewReminders()
            var error: NSError?
            eventStore.saveReminder(reminder, commit: true, error: &error)
            println("Error: \(error)")
            // TODO: Present a confirmation
          }
      })
    }
  }
  
  func formatCell(cell: UITableViewCell, indexPath: NSIndexPath) {
    if currentMode == TableMode.Options {
      dataHelper?.formatCellAtIndex(cell, index: indexPath)
    } else if currentMode == TableMode.Deals {
      cell.textLabel!.text = "HEY THERE"
    }
  }
  
  // MARK: UIWebViewDelegate
  func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
    print("Webview fail with error \(error)");
  }
  
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    return true
  }
  
  func webViewDidStartLoad(webView: UIWebView) {
    print("Webview started Loading")
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    print("Webview did finish load")
  }
}
