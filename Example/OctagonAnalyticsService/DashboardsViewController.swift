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
    
    var dashboards: [DashboardItemService] =   []

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
    
    private func loadVizDataForDashboard(_ dashboard: DashboardItemService) {
        
    }
    
    //MARK: Button Actions
    @IBAction func loadIndexPatternsListAction(_ sender: UIButton) {
        ServiceProvider.shared.loadIndexPatterns(1, pageSize: 20) { (res, error) in
            guard error == nil else {
                print("\(error!.localizedDescription)")
                return
            }
            
            if let indexPatternList = res as? IndexPatternsListResponse {
                print("Total Index Patterns = \(indexPatternList.indexPatterns.count)\n----------")

            }
        }
    }
    
    @IBAction func loadVideoContentAction(_ sender: UIButton) {
        
        let query = generatedQuery()
        ServiceProvider.shared.loadVideoContent("covid19-stats", query: query) { (res, error) in
            guard error == nil else {
                print("\(error!.localizedDescription)")
                return
            }
            
            if let videoContentList = res as? VideoContentListResponse {
                print("Total Video Contents = \(videoContentList.buckets.count)\n----------")

            }
        }
    }
    
    // Load Visualization Data
    @IBAction func loadVizDataAction(_ sender: UIButton) {
        
        let booksDashboard = dashboards.filter({ $0.id == "d76c33e0-dae5-11ea-a80d-47c665684b26"}).first
        
        guard let indexPatternId = booksDashboard?.panels.first?.visState?.indexPatternId else { return }
        
        let params = VizDataParams(indexPatternId)
        params.panelType = .pieChart
        params.timeFrom = "2015-02-01T00:00:00.000Z"
        params.timeTo = "2020-02-01T00:00:00.000Z"
        params.aggregationsArray = booksDashboard?.panels.filter({ $0.id == "3c22b390-dd2f-11ea-a80d-47c665684b26"}).first?.visState?.aggregationsArray ?? []
        
        ServiceProvider.shared.loadVisualizationData(params) { (res, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
        }
    }
        
    private func generatedQuery() -> [String: Any] {
        
        let timeFieldName = "date"
        let fieldName = "country.keyword"
        let valueToDisplayFieldName = "total"
        
        let fromDateStr = "2020-04-01"
        let toDateStr = "2020-04-30"

        let query = [ "range":
            ["\(timeFieldName)": [ "gte": fromDateStr,"lte": toDateStr]]]

        
        let datHistogram = ["field":"\(timeFieldName)", "interval": "1d"]
        
        let maxAggs = ["sum": ["field": valueToDisplayFieldName]]
        let sortAggs = ["bucket_sort": ["sort": [["max_field": ["order": "desc"]]], "size": 10]]
        
        let innerMostAggs = ["max_field": maxAggs, "count_bucket_sort": sortAggs]
        let middleLevelAggs: [String : Any] = ["terms": ["field": fieldName, "size": 500], "aggs": innerMostAggs]
        let topMostAggs: [String : Any] = ["date_histogram": datHistogram, "aggs": ["aggs_Fields": middleLevelAggs]]
                
        return ["query": query, "size": 0, "aggs": ["dateHistogramName" : topMostAggs]]
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
    }
}
