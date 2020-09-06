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
        ServiceProvider.shared.loadDashboards(1, pageSize: 100) { (res, error) in
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fromDate = dateFormatter.date(from: "2020-01-01") ?? Date()
        let toDate = dateFormatter.date(from: "2020-08-01") ?? Date()

        ServiceProvider.shared.loadVideoContent("covid19-stats", fromDate: fromDate, toDate: toDate, timeField: "date", query: query) { (res, error) in
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
        
        let testDashboard = dashboards.filter({ $0.id == "8e5cc1a0-ed33-11ea-a6cf-1f9c31f185da"}).first
        
        if testDashboard?.panels.first?.visState?.type == .inputControls {
            loadControlsVizData()
            return
        } else if testDashboard?.panels.first?.visState?.type == .tile {
            loadTilesViewVizData()
            return
        }
        
        guard let indexPatternId = testDashboard?.panels.first?.visState?.indexPatternId else { return }

        let panel = testDashboard?.panels.first
                
        let params = VizDataParams(indexPatternId)
        params.panelType = panel?.visState?.type ?? .unKnown
        if panel?.visState?.otherAggregationsArray.first?.bucketType == BucketType.dateHistogram {
            params.interval = "1d"
        }
        params.timeFrom = "now-5y"//"2015-08-16T00:00:00.000Z"
        params.timeTo = "now"//"2020-08-16T00:00:00.000Z"
        params.aggregationsArray = testDashboard?.panels.filter({ $0.id == panel?.id }).first?.visState?.aggregationsArray ?? []

        ServiceProvider.shared.loadVisualizationData(params) { (res, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let result = res as? [String: Any],
                let finalResult = result["responses"] as? [[String: Any]] {
                print("\(String(describing: finalResult.first))")
            }
        }
    }

    func loadControlsVizData() {
        
        let testDashboard = dashboards.filter({ $0.id == "ba513e20-e69a-11ea-a80d-47c665684b26"}).first
                
        guard let panel = testDashboard?.panels.first else { return }
        
        var controlsList: [ControlsParams]  =   []
        for control in (panel.visState as? InputControlsVisStateService)?.controls ?? [] {
            let params = ControlsParams(control.type, indexPatternId: control.indexPattern, fieldName: control.fieldName)
            controlsList.append(params)
        }

        let params = ControlsVizDataParams(controlsList)
        params.panelType = panel.visState?.type ?? .unKnown
        params.timeFrom = "now-5y"//"2015-08-16T00:00:00.000Z"
        params.timeTo = "now"//"2020-08-16T00:00:00.000Z"
        params.aggregationsArray = testDashboard?.panels.filter({ $0.id == panel.id}).first?.visState?.aggregationsArray ?? []

        ServiceProvider.shared.loadVisualizationData(params) { (res, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let result = res as? [String: Any],
                let finalResult = result["responses"] as? [[String: Any]] {
                print("\(String(describing: finalResult.first))")
            }
        }
    }
    
    func loadTilesViewVizData() {
        
        let testDashboard = dashboards.filter({ $0.id == "3ab21730-6c1e-11ea-9bcf-c9547acb85c3"}).first
                
        guard let panel = testDashboard?.panels.first else { return }
        
        let params = TilesVizDataParams(.images)
        params.panelType = panel.visState?.type ?? .unKnown
        params.timeFrom = "now-5y"//"2015-08-16T00:00:00.000Z"
        params.timeTo = "now"//"2020-08-16T00:00:00.000Z"
        params.aggregationsArray = testDashboard?.panels.filter({ $0.id == panel.id }).first?.visState?.aggregationsArray ?? []

        ServiceProvider.shared.loadVisualizationData(params) { (res, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let result = res as? [String: Any],
                let finalResult = result["responses"] as? [[String: Any]] {
                print("\(String(describing: finalResult.first))")
            }
        }
    }


    @IBAction func loadSavedSearchDataAction(_ sender: UIButton) {
        
        let testDashboard = dashboards.filter({ $0.id == "8e5cc1a0-ed33-11ea-a6cf-1f9c31f185da"}).first
        guard let indexPatternId = testDashboard?.panels.first?.visState?.indexPatternId else { return }

        let panel = testDashboard?.panels.first

        let params = SavedSearchDataParams(indexPatternId)
        params.panelType = .search
        params.savedSearchId = panel?.id
        params.timeFrom = "now-5y"
        params.timeTo = "now"
        params.aggregationsArray = testDashboard?.panels.filter({ $0.id == panel?.id}).first?.visState?.aggregationsArray ?? []

        ServiceProvider.shared.loadSavedSearchData(params) { (res, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let result = res as? [[String: Any]] {
                print("\(String(describing: result))")
            }
        }
    }
        
    private func generatedQuery() -> [String: Any] {
        
        let timeFieldName = "date"
        let fieldName = "country.keyword"
        let valueToDisplayFieldName = "confirmed"
        
        let fromDateStr = "2020-01-01"
        let toDateStr = "2020-07-30"

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
