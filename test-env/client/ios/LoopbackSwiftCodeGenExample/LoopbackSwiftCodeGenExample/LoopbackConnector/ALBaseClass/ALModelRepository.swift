//
//  ALModel.swift
//  loopback-sdk-ios-swift-codegen
//
//  Created by MacPro on 6/8/18.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import CoreLocation

struct CustomFormatter {
    
    static let dayMonth:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM" // Date format for data from server 2018-03-01T03:05:52.145Z
        return formatter
    }()
    
    static let normalDateTime:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MMM-dd hh:mm:ss" // Date format for data from server 2018-03-01T03:05:52.145Z
        return formatter
    }()
    
    static let iso8601Date:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" // Date format for data from server 2018-03-01T03:05:52.145Z
        return formatter
    }()
    
    static let dateWithoutMiliSeconds:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Date format for data from server 2018-03-01T03:05:52Z
        return formatter
    }()
    
}

// Some extension for convert data format of Date, Data, Location to string
extension Date {
    init(fromJSONString:String) {
        // Convert format json string to date
        self = CustomFormatter.iso8601Date.date(from: fromJSONString) ?? Date()
    }
    
    func convertToJSONString() -> String {
        return CustomFormatter.iso8601Date.string(from: self)
    }
}

extension Data {
    func convertToJSONObject() -> [AnyHashable: Any] {
        return [AnyHashable: Any]()
    }
}

extension CLLocation {
    func convertToJSONObject() -> [AnyHashable: Any] {
        return [AnyHashable: Any]()
    }
}

protocol ALModelDelagate {
    func contract() -> ALRESTContract?
}

class ALModelRepository: ALModelDelagate {
    
    internal var structType:ALBaseStruct.Type
    var className:String
    var prefixStruct:String = ""
    var postfixStruct:String = ""
    var _contract:ALRESTContract?
    
    init() {
        self.className = "Loopback"
        if let structType = NSClassFromString("\(self.prefixStruct)\(self.className)\(self.postfixStruct)") as? ALBaseStruct.Type {
            self.structType = structType
        } else {
            self.structType = ALBaseStruct.self
        }
    }
    
    init(className name: String, prefix:String, postfix:String) {
        self.className = name
        self.prefixStruct = prefix
        self.postfixStruct = postfix
        
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") ?? ""
        let structName = "\(appName).\(self.prefixStruct)\(self.className)\(self.postfixStruct)"
        if let structData =  NSClassFromString(structName) {
            if structData.isSubclass(of: ALBaseStruct.self) {
                self.structType = structData as! ALBaseStruct.Type
            } else {
                self.structType = ALBaseStruct.self
            }
        } else {
            self.structType = ALBaseStruct.self
        }
    }
    
    func contract() -> ALRESTContract? {
        self._contract = ALRESTContract()
        return self._contract
    }
    
    private func dateFrom(encodedArgument value: [AnyHashable: Any]) throws -> Date? {
        if value.count != 2 || !(((value["$type"]) as? String) == "date") || !(value["$data"] is String) {
            throw NSException(name: .invalidArgumentException, reason: "Argument doesn't follow the Date serialization format: \(value)", userInfo: nil) as! Error
        }
        if let  dateString:String = value["$data"] as? String {
            return Date(fromJSONString: dateString)
        }
        return nil
    }
    
    private func dataFrom(encodedArgument value: [AnyHashable: Any]) throws -> Data? {
        if value.count != 2 || !(((value["$type"]) as? String) == "base64") || !(value["$data"] is String) {
            throw NSException(name: .invalidArgumentException, reason: "Argument doesn't follow the Buffer serialization format: \(value)", userInfo: nil) as! Error
        }
        if let base64String:String = value["$data"] as? String {
            return Data(base64Encoded: base64String)
        }
        return nil
    }
    
    internal func convertArguments(_ prop: [AnyHashable: Any]?) -> [AnyHashable: Any]? {
        if prop == nil {
            return nil
        }
        var converted = [AnyHashable: Any]()
        for key:AnyHashable in prop!.keys {
            var value = prop![key]
            if (value is Date) {
                let jsonString:String = (value as! Date).convertToJSONString()
                value = ["$type": "date", "$data": jsonString]
            } else if (value is Data) {
                let base64string = (value as! Data).base64EncodedString(options: [])
                value = ["$type": "base64", "$data": base64string]
            } else if (value is CLLocation) {
                value = (value as! CLLocation).convertToJSONObject()
            }
            converted[key] = value
        }
        return converted
    }
    
    internal func convertProperties(_ prop: [AnyHashable: Any]?) -> [AnyHashable: Any]? {
        if prop == nil {
            return nil
        }
        var converted = [AnyHashable: Any]()
        for key:AnyHashable in prop!.keys {
            var value = prop![key]
            if (value is Date) {
                value = (value as! Date).convertToJSONString()
            } else if (value is Data) {
                value = (value as! Data).convertToJSONObject()
            } else if (value is CLLocation) {
                value = (value as! CLLocation).convertToJSONObject()
            }
            converted[key] = value
        }
        return converted
    }

}
