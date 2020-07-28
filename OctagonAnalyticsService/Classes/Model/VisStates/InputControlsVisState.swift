//
//  InputControlsVisState.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 27/07/2020.
//

import Foundation

public class InputControlsVisStateService: VisStateService {
    
    public var controls: [ControlService]  =  []
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        self.controls   =   responseModel.params.controls?.compactMap({ $0.asUIModel() }) ?? []
    }
}

public class ControlService {
    
    public enum ControlType: String {
        case range
        case list
    }

    public var id: String              =   ""
    public var indexPattern: String    =   ""
    public var fieldName: String       =   ""
    public var parent: String          =   ""
    public var label: String           =   ""
    public var type: ControlType       =   .range
    public var rangeOptions: RangeOptionsService?
    public var listOptions: ListOptionsService?
    
    init(_ responseModel: ControlsResponse) {
        self.id             =   responseModel.id ?? ""
        self.indexPattern   =   responseModel.indexPattern ?? ""
        self.fieldName      =   responseModel.fieldName ?? ""
        self.parent         =   responseModel.parent ?? ""
        self.label          =   responseModel.label ?? ""
        self.type           =   responseModel.type ?? .range
        
        switch type {
        case .range:
            rangeOptions    =   RangeOptionsService(responseModel.options)
        default:
            listOptions     =   ListOptionsService(responseModel.options)
        }
    }
}

public class RangeOptionsService {
    
    public var decimalPlaces: Int  =   0
    public var step: Int           =   0
    
    init(_ responseModel: ControlsResponse.Options?) {
        self.decimalPlaces  =   responseModel?.decimalPlaces ?? 0
        self.step           =   responseModel?.step ?? 0
    }
}

public class ListOptionsService {
    
    public var type: BucketType        =   .unKnown
    public var multiselect: Bool       =   true
    public var dynamicOptions: Bool    =   true
    public var size: Int               =   0
    public var order: String           =   ""
    
    init(_ responseModel: ControlsResponse.Options?) {
        
        if let type = responseModel?.type {
            self.type   =   BucketType(rawValue: type) ?? .unKnown
        }
        self.multiselect    =   responseModel?.multiSelect ?? true
        self.dynamicOptions =   responseModel?.dynamicOptions ?? true
        self.size           =   responseModel?.size ?? 0
        self.order          =   responseModel?.order ?? ""
    }
}
