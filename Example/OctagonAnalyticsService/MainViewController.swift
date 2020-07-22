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
        
    @IBOutlet weak var loadDashboardsButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: Overridden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        title   =   "Demo App"
        
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitle("Logout", for: .selected)
        loadDashboardsButton.isHidden = true
    }
    
    //MARK: Services
    private func login() {
        ServiceProvider.shared.loginWith("demouser", password: "demouser654321") { [weak self] (result, error) in
            
            guard error == nil else {
                print("\(error!.localizedDescription)")
                return
            }
            
            if let resp = result as? LoginResponse {
                print("Name = \(resp.userName)\nIsDemoUser = \(resp.isDemoUser)\n-----------------")
                self?.loadDashboardsButton.isHidden = false
            }
        }
    }
    
    private func logout() {
        ServiceProvider.shared.logout {[weak self] (res, error) in
            guard error == nil else {
                print("\(error!.localizedDescription)")
                return
            }
            
            if let _ = res as? Bool {
                print("Logged Out\n----------")
                self?.loadDashboardsButton.isHidden = true
            }
        }
    }
    
    private func loadDashboards() {
        ServiceProvider.shared.loadDashboards(1, pageSize: 20) { (res, error) in
            guard error == nil else {
                print("\(error!.localizedDescription)")
                return
            }
            
            if let list = res as? DashboardListResponse {
                print("DashboardList")
                print("Total Dashboards = \(list.total)\n----------")
            }
        }
    }
    //MARK: Button Action
    @IBAction func loginButtonAction(_ sender: UIButton) {
        
        if !sender.isSelected {
            login()
        } else {
            logout()
        }
        
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func loadDashboardsButtonAction(_ sender: UIButton) {
        loadDashboards()
    }
    
}
