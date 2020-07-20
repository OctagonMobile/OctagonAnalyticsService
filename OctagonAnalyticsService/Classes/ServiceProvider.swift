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
    
}

protocol OAServiceErrorProtocol: LocalizedError {
    var title: String? { get }
    var code: Int { get }
}

public struct OAServiceError: OAServiceErrorProtocol {
    var title: String?
    var code: Int
    public var errorDescription: String? { return _description }
    public var failureReason: String? { return _description }

    private var _description: String

    init(title: String? = nil, description: String, code: Int) {
        self.title = title ?? "Error"
        self._description = description
        self.code = code
    }
}
