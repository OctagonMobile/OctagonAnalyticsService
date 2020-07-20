//
//  MainViewController.swift
//  OctagonAnalyticsService_Example
//
//  Created by Rameez on 16/07/2020.
//  Copyright © 2020 OctagonMobile. All rights reserved.
//

import UIKit
import Alamofire
import OctagonAnalyticsService

class MainViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ServiceProvider.shared.loginWith("demouser", password: "demouser654321") { (result, error) in
            
            guard error == nil else {
                print("\(error!.localizedDescription)")
                return
            }
            
            if let resp = result as? LoginResponse {
                print("Name = \(resp.userName)\nDemoUser = \(resp.isDemoUser)")
            }
        }
    }
    
}
