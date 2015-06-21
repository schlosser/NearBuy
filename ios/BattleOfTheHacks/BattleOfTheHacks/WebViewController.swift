//
//  WebViewController.swift
//  BattleOfTheHacks
//
//  Created by Matt on 6/21/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

  var webView: UIWebView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let bounds: CGRect = UIScreen.mainScreen().bounds
    self.view = UIWebView(frame: CGRectMake(0, 40.0, self.bounds.size.width, self.bounds.height-40.0)

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
