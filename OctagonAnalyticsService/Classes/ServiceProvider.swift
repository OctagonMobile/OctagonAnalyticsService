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
        
        if !(params is ControlsVizDataParams) && !(params is TilesVizDataParams) {
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
                completion?(result)
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
    
    public func loadVideoContent(_ indexPatternName: String, query: [String: Any], completion: CompletionBlock?) {
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
}
