//
//  NeoGraph.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 27/07/2020.
//

import Foundation

public class NeoGraphService {
    
    public var nodesList: [NeoGraphNodeService]   =   []
    public var edgesList: [NeoGraphEdgeService]   =   []

    //MARK: Functions
//    func mapping(map: Map) {
//
//        guard let data = map.JSON["data"] as? [[String: Any]] else { return }
//
//        nodesList.removeAll()
//        edgesList.removeAll()
//
//        for item in data {
//            guard let graphDict = item["graph"] as? [String: Any] else { return }
//            let nodesArray = graphDict["nodes"] as? [[String: Any]] ?? []
//            let relationshipsArray = graphDict["relationships"] as? [[String: Any]] ?? []
//
//            let graphNodeList = Mapper<NeoGraphNode>().mapArray(JSONArray: nodesArray)
//            let edges = Mapper<NeoGraphEdge>().mapArray(JSONArray: relationshipsArray)
//            nodesList.append(contentsOf: graphNodeList)
//            edgesList.append(contentsOf: edges)
//        }
//    }
}


public class NeoGraphNodeService {

    public var id: String?
    
    public var name: String?

    public var number: String?

    public var imageUrl: String?

    //MARK: Functions
//    func mapping(map: Map) {
//        id              <-      map["id"]
//        name            <-      map["properties.name"]
//        number          <-      map["properties.number"]
//        imageUrl        <-      map["properties.url"]
//    }
}

public class NeoGraphEdgeService {
    
    public var id: String?
    public var type: String?
    public var startNodeId: String?
    public var endNodeId: String?
    
    //MARK: Functions
    
//    func mapping(map: Map) {
//        id                  <-      map["id"]
//        type                <-      map["type"]
//        startNodeId         <-      map["startNode"]
//        endNodeId           <-      map["endNode"]
//    }
}
