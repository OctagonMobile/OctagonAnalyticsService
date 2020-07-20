//
//  LoginResponseBase.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 20/07/2020.
//

import Foundation

//MARK: Login Models
class LoginResponseBase: Decodable {
    
    var userName: String
    var isDemoUser: Bool

    private enum CodingKeys: String, CodingKey {
        case userName   =   "username"
        case tenants    =   "tenants"
        enum NestedCodingKeys: String, CodingKey {
            case isDemoUser   =   "demouser"
        }
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        let tenantsContainer = try container.nestedContainer(keyedBy: CodingKeys.NestedCodingKeys.self, forKey: .tenants)

        self.userName   = try container.decode(String.self, forKey: .userName)
        self.isDemoUser = try tenantsContainer.decode(Bool.self, forKey: .isDemoUser)
    }
    
    func asUIModel() -> LoginResponse {
        return LoginResponse(self)
    }
}

public class LoginResponse {
    public var userName: String
    public var isDemoUser: Bool
 
    init(_ responseModel: LoginResponseBase) {
        self.userName = responseModel.userName
        self.isDemoUser = responseModel.isDemoUser
    }
}

//MARK: Version - 7.3.2
class LoginResponse732: LoginResponseBase {
    var isGlobalTenant: Bool
    var isAdminTenant: Bool
    
    private enum CodingKeys: String, CodingKey {
        case tenants    =   "tenants"
        enum NestedCodingKeys: String, CodingKey {
            case isGlobalTenant =   "global_tenant"
            case isAdminTenant  =   "admin_tenant"
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        let tenantsContainer = try container.nestedContainer(keyedBy: CodingKeys.NestedCodingKeys.self, forKey: .tenants)

        self.isGlobalTenant = try tenantsContainer.decode(Bool.self, forKey: .isGlobalTenant)
        self.isAdminTenant = try tenantsContainer.decode(Bool.self, forKey: .isAdminTenant)
        try super.init(from: decoder)
    }
}
