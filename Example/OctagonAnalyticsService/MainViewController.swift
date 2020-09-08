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
        
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: Overridden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        title   =   "Demo App"
        
        loginButton.setTitle("Login", for: .normal)
    }
    
    //MARK: Services
    private func login() {
        ServiceProvider.shared.loginWith("demouser", password: "demouser654321") { [weak self] (result) in
            
            switch result {
                case .success(let data):
                    if let resp = data as? LoginResponse {
                        print("Name = \(resp.userName)\nIsDemoUser = \(resp.isDemoUser)\n-----------------")
                        let dashboards = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "DashboardsViewController")
                        self?.navigationController?.pushViewController(dashboards, animated: true)

                    }
            case .failure(let error):
                print("\(error.localizedDescription)")
            }

        }
    }
    
    

    
    //MARK: Button Action
    @IBAction func loginButtonAction(_ sender: UIButton) {
        
        login()

    }
    
}
