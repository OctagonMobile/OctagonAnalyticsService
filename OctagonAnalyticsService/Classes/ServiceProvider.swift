//
//  ServiceProvider.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 19/07/2020.
//

import Foundation
import Alamofire

public typealias CompletionBlock = (_ result: Any?,_ error: OAServiceError?) -> Void

public class ServiceProvider {
    
    public static var shared   = ServiceProvider()
    
    var indexPatternsList: [IndexPatternService]    =   []
    
    //MARK: Authentication
    public func loginWith(_ userName: String, password: String, completion: CompletionBlock?) {
        
        let request = AuthenticationBuilder.login(userId: userName, password: password)
        
        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                completion?(nil, serviceError)
            case .success(let value):
                do {
                    let decoder = JSONDecoder()                    
                    let loginReponseModel = try decoder.decode(ServiceConfiguration.version.loginResponseModel.self, from: value)
                    completion?(loginReponseModel.asUIModel(), nil)
                } catch let error {
                    let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                    completion?(nil, serviceError)
                }
            }
        }
    }
    
    public func logout(_ completion: CompletionBlock?) {
        let request = AuthenticationBuilder.logout
        
        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                completion?(nil, serviceError)
            case .success( _):
                completion?(true, nil)
            }
        }
    }
    
    //MARK: Dashboards
    public func loadDashboards(_ pageNumber: Int, pageSize: Int, completion: CompletionBlock?) {
        
        //Update Indexpatterns List which is used for Visualization Data Service
        loadIndexPatterns(1, pageSize: 1000, completion: nil)
        
        let request = DashboardServiceBuilder.loadDashboards(pageNumber: pageNumber, pageSize: pageSize)
        
        AF.request(request).responseData {[weak self] (response) in
            switch response.result {
            case .failure(let error):
                let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                completion?(nil, serviceError)
            case .success(let value):
                do {
                    let dashboardListModel = try JSONDecoder().decode(ServiceConfiguration.version.dashboardListModel.self, from: value)
                    self?.UpdateVisStateFor(dashboardListModel, completion: completion)
                } catch let error {
                    let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                    completion?(nil, serviceError)
                }
            }
        }
    }
    
    //MARK: Visualization Data
    public func loadVisualizationData(_ params: VizDataParamsBase, completion: CompletionBlock?) {
        
        var indexPatternName = ""
        
        if !(params is ControlsVizDataParams) && !(params is TilesVizDataParams) {
            guard let indexPattern = indexPatternsList.filter({ $0.id == params.indexPatternId }).first else {
                    let err = OAServiceError(description: "Visualization Not found", code: 1000)
                    completion?(nil, err)
                    return
            }
            indexPatternName = indexPattern.title
        }
                        
        let request = DashboardServiceBuilder.loadVisualizationData(indexPatternName: indexPatternName, vizDataParams: params)
        
        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                completion?(nil, serviceError)
            case .success(let value):
                
                do {
                    let result = try JSONSerialization.jsonObject(with: value, options: .allowFragments)
                    let resp = params.postResponseProcedure(result)
                    completion?(resp, nil)

                } catch let error {
                    let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                    completion?(nil, serviceError)
                }
            }
        }

    }
    
    //MARK: SavedSearch
    public func loadSavedSearchData(_ params: SavedSearchDataParams, completion: CompletionBlock?) {
                
        guard let savedSearchId = params.savedSearchId else {
            let serviceError = OAServiceError(description: "Missing SavedSearch ID", code: 1000)
            completion?(nil, serviceError)
            return
        }
        let info = PanelInfo(savedSearchId, type: "search")
        
        loadVisStateDataFor([info]) { [weak self] (res, err) in
            
            guard err == nil else {
                completion?(nil, err)
                return
            }

            guard let visStateContent = res as? VisStateContainer else {
                let serviceError = OAServiceError(description: "Something went wrong, please retry", code: 1000)
                completion?(nil, serviceError)
                return
            }

            guard let indexPattern = self?.indexPatternsList.filter({ $0.id == params.indexPatternId }).first else {
                    let err = OAServiceError(description: "SavedSearch Not found", code: 1000)
                    completion?(nil, err)
                    return
            }
                    
            let sort = visStateContent.visStateHolder?.first?.sortList ?? []
            let request = DashboardServiceBuilder.loadSavedSearchData(indexPatternName: indexPattern.title, sort: sort, searchDataParams: params)
            
            AF.request(request).responseData { (response) in
                switch response.result {
                case .failure(let error):
                    let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                    completion?(nil, serviceError)
                case .success(let value):
                    
                    do {
                        let result = try JSONSerialization.jsonObject(with: value, options: .allowFragments)
                        
                        let visStateHolder = visStateContent.visStateHolder?.first
                        let resp = params.postResponseProcedure(result, visStateHolder: visStateHolder)
                        completion?(resp, nil)
                    } catch let error {
                        let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                        completion?(nil, serviceError)
                    }
                }
            }

        }
    }

    //MARK: Canvas
    public func loadCanvasList(_ pageNumber: Int, pageSize: Int, completion: CompletionBlock?) {
                
        let request = CanvasServiceBuilder.loadCanvasList(pageNumber: pageNumber, pageSize: pageSize)
        
        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                completion?(nil, serviceError)
            case .success(let value):
                do {
                    let canvasListModel = try JSONDecoder().decode(ServiceConfiguration.version.canvasListModel.self, from: value)
                    completion?(canvasListModel.asUIModel(), nil)
                } catch let error {
                    let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                    completion?(nil, serviceError)
                }
            }
        }
    }

    
    //MARK: Video Data
    public func loadIndexPatterns(_ pageNumber: Int, pageSize: Int, completion: CompletionBlock?) {
        let request = VideoServiceBuilder.loadIndexPatterns(pageNumber: pageNumber, pageSize: pageSize)

        AF.request(request).responseData {[weak self] (response) in
            switch response.result {
            case .failure(let error):
                let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                completion?(nil, serviceError)
            case .success(let value):
                do {
                    let indexPatternListModel = try JSONDecoder().decode(ServiceConfiguration.version.indexPatternListModel.self, from: value)
                    let ipListModel = indexPatternListModel.asUIModel()
                    self?.indexPatternsList = ipListModel.indexPatterns
                    completion?(ipListModel, nil)

                } catch let error {
                    let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                    completion?(nil, serviceError)
                }
            }
        }
    }
    
    private var dispatchGroup = DispatchGroup()
    private var videoContentListResponseArray: [VideoContentListResponse] = []
    private var queryDateFormatter: DateFormatter {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSSZ"
        return dateFormat
    }
    
    public func loadVideoContent(_ indexPatternName: String, fromDate: Date, toDate: Date, timeField: String, query: [String: Any], completion: CompletionBlock?) {
        
        // Reset response
        videoContentListResponseArray.removeAll()
        
        let queryPart = videoDataQuery(fromDate, toDate: toDate, timeField: timeField)
        let queryForHitCount: [String: Any] = ["query": queryPart, "size": 0]

        getNumberOfRecordsFor(indexPatternName, query: queryForHitCount) { [weak self] (res, error) in
            guard let strongSelf = self, error == nil else {
                completion?(nil, error)
                return
            }
            
            guard let total = res as? CGFloat else {
                let err = OAServiceError(description: "Please try again", code: 1000)
                completion?(nil, err)
                return
            }
            
            //Max allowed buckets = 10,000. We need to devide the request into multiple request
            let totalNumberOfRequests = (total / 10000).rounded(.up)
            if totalNumberOfRequests == 0 {
                let err = OAServiceError(description: "No data found", code: 1000)
                completion?(nil, err)
            } else {
                
                let dateDifference = toDate.timeIntervalSince(fromDate)
                let dif = dateDifference / TimeInterval(totalNumberOfRequests)
                      
                var from = fromDate
                var to = from.addingTimeInterval(dif)

                for _ in 0 ..< Int(totalNumberOfRequests) {

                    let queryPart = strongSelf.videoDataQuery(from, toDate: to, timeField: timeField)
                    var finalQuery = query
                    finalQuery["query"] = queryPart
                    finalQuery["size"] = 0

                    self?.dispatchGroup.enter()
                    self?.loadVideoData(indexPatternName, query: finalQuery) { (res, err) in
                        guard err == nil else {
                            self?.dispatchGroup.leave()
                            return
                        }
                        
                        if let videoContentListObj = res as? VideoContentListResponse {
                            self?.videoContentListResponseArray.append(videoContentListObj)
                        }
                        self?.dispatchGroup.leave()
                    }
                    
                    from = to.addingTimeInterval(1)
                    to = from.addingTimeInterval(dif)
                }
                
                self?.dispatchGroup.notify(queue: .main) {
                    let list = (self?.videoContentListResponseArray.reduce([], { (res, video) -> [VideoContentService] in
                        return res + video.buckets
                    }) ?? []).sorted(by: { $1.date != nil && $0.date?.compare($1.date!) == .orderedAscending })
                    completion?(VideoContentListResponse(list), nil)
                }
            }
        }
    }
}

//MARK: Private Functions
extension ServiceProvider {
    
    func UpdateVisStateFor(_ dashboardListModel: DashboardListReponseBase, completion: CompletionBlock?) {

        let idsList = dashboardListModel.dashboards.compactMap({ $0.allPanelsInfoList })
        let panelsIdList: [PanelInfo] = idsList.reduce([], +)
        guard panelsIdList.count > 0 else {
            completion?(nil, nil)
            return
        }
        loadVisStateDataFor(panelsIdList) { (res, err) in

            guard err == nil else {
                completion?(nil, err)
                return
            }

            guard let visStateContent = res as? VisStateContainer else {
                let serviceError = OAServiceError(description: "Something went wrong, please retry", code: 1000)
                completion?(nil, serviceError)
                return
            }

            dashboardListModel.dashboards.forEach { (dashboards) in
                var panels: [PanelBase] =   []
                dashboards.attributes.panelsJsonList.forEach { (dict) in
                    guard let id = dict["id"] as? String,
                        let visState = visStateContent.visStateHolder?.filter({ $0.id == id}).first else { return }

                    do {
                        let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                        let panel = try JSONDecoder().decode(ServiceConfiguration.version.panelModel.self, from: data)
                        panel.visState  =   visState
                        panels.append(panel)
                    }
                    catch let error {
                        let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                        completion?(nil, serviceError)
                    }
                }

                dashboards.attributes.panels = panels
                dashboards.attributes.panels.forEach({ $0.dashboardItemBase = dashboards })
            }

            completion?(dashboardListModel.asUIModel(), nil)
        }

    }
        
    func loadVisStateDataFor(_ panelInfo: [PanelInfo], completion: CompletionBlock?) {
        
        let request = DashboardServiceBuilder.loadVisStateData(panelInfo: panelInfo)
        
        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                completion?(nil, serviceError)
            case .success(let value):
                do {

                    let content = try JSONDecoder().decode(VisStateContainer.self, from: value)
                    completion?(content, nil)

                } catch let error {
                    let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                    completion?(nil, serviceError)
                }
            }
        }
        
    }
    
    func loadVideoData(_ indexPatternName: String, query: [String: Any], completion: CompletionBlock?) {
        let request = VideoServiceBuilder.loadVideoData(indexPatternName: indexPatternName, query: query)

        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                completion?(nil, serviceError)
            case .success(let value):
                do {
                    let videoResponseModel = try JSONDecoder().decode(VideoContentListResponseBase.self, from: value)
                    completion?(videoResponseModel.asUIModel(), nil)
                } catch let error {
                    let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                    completion?(nil, serviceError)
                }
            }
        }

    }
    
    func getNumberOfRecordsFor(_ indexPatternName: String, query: [String: Any], completion: CompletionBlock?) {
        
        let request = VideoServiceBuilder.loadVideoDataTotalCount(indexPatternName: indexPatternName, query: query)

        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                completion?(nil, serviceError)
            case .success(let value):
                do {
                    let json = try JSONSerialization.jsonObject(with: value, options: []) as? [String: Any]
                    let result = json?["hits"] as? [String: Any]
                    let total = ServiceConfiguration.version.getTotalFrom(result)
                    completion?(total, nil)
                } catch let error {
                    let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                    completion?(nil, serviceError)
                }
            }
        }
    }
    
    func videoDataQuery(_ fromDate: Date, toDate: Date, timeField: String) -> [String: Any] {
        let fromDateStr = queryDateFormatter.string(from: fromDate)
        let toDateStr = queryDateFormatter.string(from: toDate)

        let queryPart = [ "range":
            ["\(timeField)": [ "gte": fromDateStr,"lte": toDateStr]]]

        return queryPart
    }
}
