//
//  Helper.swift
//  Alamofire
//
//  Created by Rameez on 22/07/2020.
//

import Foundation

//MARK: ParseJsonArrayProtocol
protocol ParseJsonArrayProtocol{
    func parse<T : Decodable>(_ jsonArray: [[String: Any]], type: T.Type) throws -> [T]
}

extension ParseJsonArrayProtocol {
    
    func parse<T : Decodable>(_ jsonArray: [[String: Any]], type: T.Type) throws -> [T] {
        
        let list = jsonArray.compactMap { (dict) -> T? in
            if let dataString = dict.jsonStringRepresentation, let data = dataString.data(using: .utf8)  {
                do {
                    return try JSONDecoder().decode(type.self, from: data)
                } catch let err {
                    print(err.localizedDescription)
                }
//                return try? JSONDecoder().decode(type.self, from: data)
            }
            return nil
        }
        return list
    }
}


//MARK: Codable Extesnions
struct JSONCodingKeys: CodingKey {
    var stringValue: String

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer {

    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }

    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }

    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {

    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            // See if the current value in the JSON array is `null` first and prevent infite recursion with nested arrays.
            if try decodeNil() {
                continue
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }

    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {

        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

//MARK: Dictionary
extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.fragmentsAllowed]) else {
            return nil
        }

        return String(data: theJSONData, encoding: .ascii)
    }
}


extension String {
    func formattedDate(_ format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}


//This extension is used temporary purpose
extension Date {

    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func toFormat(_ format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.locale = Locale.current
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }

    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}

extension URL {

    func URLByAppendingQueryParameters(_ params: [String: String]?) -> URL? {
        guard let parameters = params,
          var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }

        var mutableQueryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        mutableQueryItems.append(contentsOf: parameters.compactMap({ URLQueryItem(name: $0, value: $1)}))

        urlComponents.queryItems = mutableQueryItems
        return urlComponents.url
    }
}
