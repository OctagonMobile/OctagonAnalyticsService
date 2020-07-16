//
//  MainViewController.swift
//  OctagonAnalyticsService_Example
//
//  Created by Rameez on 16/07/2020.
//  Copyright © 2020 OctagonMobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class MainViewController: UIViewController {
    
    var serviceConfig: ServiceConfiguration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    private func initialSetup() {
        serviceConfig = ServiceConfiguration("")
    }
}
