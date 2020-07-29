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
                        panel.visState  =   visState.visStateBase
                        panels.append(panel)
                    }
                    catch let error {
                        let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                        completion?(nil, serviceError)
                    }
                }

                dashboards.attributes.panels = panels
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
}
