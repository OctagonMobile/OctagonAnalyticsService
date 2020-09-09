//
//  ServiceProvider.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 19/07/2020.
//

import Foundation
import Alamofire

public typealias ServiceResult = Result<Any?, OAError>
public typealias CompletionBlock = (ServiceResult) -> Void

public class ServiceProvider: OAErrorHandler {
    
    public static var shared   = ServiceProvider()
    
    var indexPatternsList: [IndexPatternService]    =   []
    
    //MARK: Authentication
    public func loginWith(_ userName: String, password: String, completion: CompletionBlock?) {
        
        let request = AuthenticationBuilder.login(userId: userName, password: password)
        
        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                completion?(.failure(self.parse(error: error)))
            case .success(let value):
                do {
                    let decoder = JSONDecoder()                    
                    let loginReponseModel = try decoder.decode(ServiceConfiguration.version.loginResponseModel.self, from: value)
                    completion?(.success(loginReponseModel.asUIModel()))
                } catch let error {
                    completion?(.failure(self.parse(error: error)))
                }
            }
        }
    }
    
    public func logout(_ completion: CompletionBlock?) {
        let request = AuthenticationBuilder.logout
        
        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                completion?(.failure(self.parse(error: error)))
            case .success( _):
                completion?(.success(true))
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
                if let self = self {
                    completion?(.failure(self.parse(error: error)))
                }
            case .success(let value):
                do {
                    let dashboardListModel = try JSONDecoder().decode(ServiceConfiguration.version.dashboardListModel.self, from: value)
                    self?.UpdateVisStateFor(dashboardListModel, completion: completion)
                } catch let error {
                    if let self = self {
                        completion?(.failure(self.parse(error: error)))
                    }
                }
            }
        }
    }
    
    //MARK: Visualization Data
    public func loadVisualizationData(_ params: VizDataParamsBase, completion: CompletionBlock?) {
        
        var indexPatternName = ""
        
        if !(params is ControlsVizDataParams) {
            guard let indexPattern = indexPatternsList.filter({ $0.id == params.indexPatternId }).first else {
                completion?(.failure(OAError.unknown("Visualization Not found")))
                return
            }
            indexPatternName = indexPattern.title
        }
                        
        let request = DashboardServiceBuilder.loadVisualizationData(indexPatternName: indexPatternName, vizDataParams: params)
        
        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                completion?(.failure(self.parse(error: error)))
            case .success(let value):
                
                do {
                    let result = try JSONSerialization.jsonObject(with: value, options: .allowFragments)
                    let resp = params.postResponseProcedure(result)
                    completion?(.success(resp))
                } catch let error {
                    completion?(.failure(self.parse(error: error)))
                }
            }
        }

    }
    
    //MARK: SavedSearch
    public func loadSavedSearchData(_ params: SavedSearchDataParams, completion: CompletionBlock?) {
                
        guard let savedSearchId = params.savedSearchId else {
            completion?(.failure(OAError.unknown("Missing SavedSearch ID")))
            return
        }
        let info = PanelInfo(savedSearchId, type: "search")
        
        loadVisStateDataFor([info]) { [weak self] (result) in
            switch result {
            case .failure(let error):
                if let self = self {
                    completion?(.failure(self.parse(error: error)))
                }
            case .success(let data):
                guard let visStateContent = data as? VisStateContainer else {
                    completion?(.failure(OAError.unknown("Something went wrong, please retry")))
                    return
                }
                
                guard let indexPattern = self?.indexPatternsList.filter({ $0.id == params.indexPatternId }).first else {
                    completion?(.failure(OAError.unknown("SavedSearch Not found")))
                    return
                }
                
                let sort = visStateContent.visStateHolder?.first?.sortList ?? []
                let request = DashboardServiceBuilder.loadSavedSearchData(indexPatternName: indexPattern.title, sort: sort, searchDataParams: params)
                
                AF.request(request).responseData { (response) in
                    switch response.result {
                    case .failure(let error):
                        if let self = self {
                            completion?(.failure(self.parse(error: error)))
                        }
                    case .success(let value):
                        
                        do {
                            let result = try JSONSerialization.jsonObject(with: value, options: .allowFragments)
                            
                            let visStateHolder = visStateContent.visStateHolder?.first
                            let resp = params.postResponseProcedure(result, visStateHolder: visStateHolder)
                            completion?(.success(resp))
                        } catch let error {
                            if let self = self {
                                completion?(.failure(self.parse(error: error)))
                            }
                        }
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
                completion?(.failure(self.parse(error: error)))
            case .success(let value):
                do {
                    let canvasListModel = try JSONDecoder().decode(ServiceConfiguration.version.canvasListModel.self, from: value)
                    completion?(.success(canvasListModel.asUIModel()))
                } catch let error {
                    completion?(.failure(self.parse(error: error)))
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
                if let self = self {
                    completion?(.failure(self.parse(error: error)))
                }
            case .success(let value):
                do {
                    let indexPatternListModel = try JSONDecoder().decode(ServiceConfiguration.version.indexPatternListModel.self, from: value)
                    let ipListModel = indexPatternListModel.asUIModel()
                    self?.indexPatternsList = ipListModel.indexPatterns
                    completion?(.success(ipListModel))

                } catch let error {
                    if let self = self {
                        completion?(.failure(self.parse(error: error)))
                    }
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
        getNumberOfRecordsFor(indexPatternName, query: queryForHitCount) { [weak self] (result) in
            
            switch result {
            case .failure(_):
                completion?(result)
            case .success(let res):
                guard let strongSelf = self else {
                    completion?(.failure(OAError.unknown("")))
                    return
                }
                guard let total = res as? CGFloat else {
                    completion?(.failure(OAError.unknown("Please try again")))
                    return
                }
                
                //Max allowed buckets = 10,000. We need to devide the request into multiple request
                let totalNumberOfRequests = (total / 10000).rounded(.up)
                if totalNumberOfRequests == 0 {
                    completion?(.failure(OAError.unknown("No data found")))
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
                        self?.loadVideoData(indexPatternName, query: finalQuery) { (result) in
                            switch result {
                            case .failure( _):
                                self?.dispatchGroup.leave()
                                return
                            case .success(let res):
                                if let videoContentListObj = res as? VideoContentListResponse {
                                    self?.videoContentListResponseArray.append(videoContentListObj)
                                }
                                self?.dispatchGroup.leave()
                            }
                        }
                        
                        from = to.addingTimeInterval(1)
                        to = from.addingTimeInterval(dif)
                    }
                    
                    self?.dispatchGroup.notify(queue: .main) {
                        let list = (self?.videoContentListResponseArray.reduce([], { (res, video) -> [VideoContentService] in
                            return res + video.buckets
                        }) ?? []).sorted(by: { $1.date != nil && $0.date?.compare($1.date!) == .orderedAscending })
                        completion?(.success(VideoContentListResponse(list)))
                    }
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
            completion?(.failure(OAError.unknown("")))
            return
        }
        loadVisStateDataFor(panelsIdList) { (result) in

            switch result {
            case .success(let data):
                guard let visStateContent = data as? VisStateContainer else {
                    completion?(.failure(OAError.unknown("Something went wrong, please retry")))
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
                            completion?(.failure(self.parse(error: error)))
                        }
                    }

                    dashboards.attributes.panels = panels
                    dashboards.attributes.panels.forEach({ $0.dashboardItemBase = dashboards })
                }

                completion?(.success(dashboardListModel.asUIModel()))
            case .failure(_):
                completion?(result)
            }
        }

    }
        
    func loadVisStateDataFor(_ panelInfo: [PanelInfo], completion: CompletionBlock?) {
        
        let request = DashboardServiceBuilder.loadVisStateData(panelInfo: panelInfo)
        
        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                completion?(.failure(self.parse(error: error)))
            case .success(let value):
                do {

                    let content = try JSONDecoder().decode(VisStateContainer.self, from: value)
                    completion?(.success(content))

                } catch let error {
                    completion?(.failure(self.parse(error: error)))
                }
            }
        }
        
    }
    
    func loadVideoData(_ indexPatternName: String, query: [String: Any], completion: CompletionBlock?) {
        let request = VideoServiceBuilder.loadVideoData(indexPatternName: indexPatternName, query: query)

        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                completion?(.failure(self.parse(error: error)))
            case .success(let value):
                do {
                    let videoResponseModel = try JSONDecoder().decode(VideoContentListResponseBase.self, from: value)
                    completion?(.success(videoResponseModel.asUIModel()))
                } catch let error {
                    completion?(.failure(self.parse(error: error)))
                }
            }
        }

    }
    
    func getNumberOfRecordsFor(_ indexPatternName: String, query: [String: Any], completion: CompletionBlock?) {
        
        let request = VideoServiceBuilder.loadVideoDataTotalCount(indexPatternName: indexPatternName, query: query)

        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                completion?(.failure(self.parse(error: error)))
            case .success(let value):
                do {
                    let json = try JSONSerialization.jsonObject(with: value, options: []) as? [String: Any]
                    let result = json?["hits"] as? [String: Any]
                    let total = ServiceConfiguration.version.getTotalFrom(result)
                    completion?(.success(total))
                } catch let error {
                    completion?(.failure(self.parse(error: error)))
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
