//
//  ServiceProvider.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 19/07/2020.
//

import Foundation
import Alamofire

public typealias CompletionBlock = (_ result: Any?,_ error: OAServiceError?) -> Void

public struct ServiceProvider {
    
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
        
        AF.request(request).responseData { (response) in
            switch response.result {
            case .failure(let error):
                let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                completion?(nil, serviceError)
            case .success(let value):
                do {
                    let decoder = JSONDecoder()
                    let dashboardListModel = try decoder.decode(ServiceConfiguration.version.dashboardListModel.self, from: value)
                    completion?(dashboardListModel.asUIModel(), nil)
                } catch let error {
                    let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                    completion?(nil, serviceError)
                }
            }
        }

    }
}
