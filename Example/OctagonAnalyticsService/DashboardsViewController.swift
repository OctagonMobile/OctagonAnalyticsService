//
//  DashboardsViewController.swift
//  OctagonAnalyticsService_Example
//
//  Created by Rameez on 23/07/2020.
//  Copyright © 2020 OctagonMobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class DashboardsViewController: UIViewController {
    
    var dashboards: [DashboardItem] =   []

    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title   =   "Dashboards"
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        tableView.delegate = self
        loadDashboards()
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
                
                self.dashboards = list.dashboards
                self.tableView.reloadData()
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
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func logoutButtonAction(_ sender: UIButton) {
        logout()
    }
    
    private func loadVizDataForDashboard(_ dashboard: DashboardItem) {
        
    }
}

extension DashboardsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dashboards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

        if (cell != nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.text = dashboards[indexPath.row].title
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dashboard = dashboards[indexPath.row]
        
        ServiceProvider.shared.loadAndUpdateVisStateForPanels(dashboard) { (res, error) in
            guard error == nil else {
                print("\(error!.localizedDescription)")
                return
            }

            print("VisState updated for Dashboard = \(dashboard.title)")
            self.loadVizDataForDashboard(dashboard)
        }
    }
}
