//
//  ControlsVizDataParams.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 24/08/2020.
//

import Foundation

public class ControlsParams {
    var type: ControlService.ControlType    =   .list
    var indexPatternId: String
    var fieldName: String
    
    var indexPatternTitle: String {
        return ServiceProvider.shared.indexPatternsList.filter({ $0.id == indexPatternId }).first?.title ?? ""
    }
    
    public init(_ type: ControlService.ControlType, indexPatternId: String, fieldName: String) {
        self.type   = type
        self.indexPatternId =   indexPatternId
        self.fieldName      =   fieldName
    }
}

public class ControlsVizDataParams: VizDataParamsBase {
    
    public var controlsParams: [ControlsParams] =   []
    
    public init(_ controlsParams: [ControlsParams]) {
        super.init([])
        self.controlsParams =   controlsParams
    }
    
    override func generatedQueryDataForVisualization(_ indexPatternName: String, params: VizDataParamsBase?) -> Data? {
        
        guard let controlsParams = params as? ControlsVizDataParams else { return nil }
        
        return getInputControlsQueryData(controlsParams)
    }
    
    func getInputControlsQueryData(_ params: ControlsVizDataParams?) -> Data {
        
        var finalContent = ""
        
        for control in controlsParams {
                        
            if control.type == .list {
                finalContent += getOptionsListAggs(control)
            } else {
                finalContent += getRangeSliderAggs(control)
            }
        }
        
        return finalContent.data(using: .utf8)!
    }
    
    func getRangeSliderAggs(_ control: ControlsParams) -> String {
        let indexJson: [String: Any] = ["index": control.indexPatternTitle,
                                        "ignore_unavailable": true]
        
        let aggsDict =
            ["maxAgg" : ["max": ["field": control.fieldName]],
                "minAgg" : ["min": ["field": control.fieldName]]]

        let queryJSON: [String: Any]  =
            ["query":
                ["bool":
                    [
                        "must": [],
                        "must_not": [],
                        "filter": []
                    ]
                ],
             "size": 100,
             "_source": [
               "excludes": []
             ],
             "aggs": aggsDict,
             "script_fields": [:]
        ]

        let indexJsonString = indexJson.jsonStringRepresentation ?? ""
        let queryJSONString = queryJSON.jsonStringRepresentation ?? ""

        return indexJsonString + "\n" + queryJSONString + "\n"
    }
    
    func getOptionsListAggs(_ control: ControlsParams) -> String {
        
        let indexJson: [String: Any] = ["index": control.indexPatternTitle,
                                        "ignore_unavailable": true]

        let aggsDict =
            ["termsAgg" : ["terms": ["order": ["_count": "desc"],
                                     "field": control.fieldName]]]

        let queryJSON: [String: Any]  =
            ["query":
                ["bool":
                    [
                        "must": [],
                        "must_not": [],
                        "filter": []
                    ]
                ],
             "size": 100,
             "_source": [
               "excludes": []
             ],
             "aggs": aggsDict,
             "script_fields": [:]
        ]

        let indexJsonString = indexJson.jsonStringRepresentation ?? ""
        let queryJSONString = queryJSON.jsonStringRepresentation ?? ""

        return indexJsonString + "\n" + queryJSONString + "\n"
    }

}
