//
//  ALRESTContract.swift
//  loopback-sdk-ios-swift-codegen
//
//  Created by MacPro on 6/7/18.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation

let ALRESTContractDefaultVerb:String = "POST"

class ALRESTContractItem: NSObject {
    
    var pattern = ""
    var verb = ""
    var multipart = false
    var binaryCallback = false
    
    init(pattern: String) {
        super.init()
        
        self.pattern = pattern
        self.verb = ALRESTContractDefaultVerb
    }
    
    init(pattern: String, verb: String) {
        super.init()
        
        self.pattern = pattern
        self.verb = verb
        
    }
    
    init(pattern: String, verb: String, multipart: Bool) {
        super.init()
        
        self.pattern = pattern
        self.verb = verb
        self.multipart = multipart
        
    }
}

class ALRESTContract {
    
    var dict:[AnyHashable:Any]
    
    init() {
        self.dict = [AnyHashable:Any]()
    }
    
    func add(_ item: ALRESTContractItem, forMethod method: String) {
        self.dict[method] = item
    }
    
    func addItems(from contract: ALRESTContract) {
        for (k, v) in contract.dict {
            self.dict[k] = v
        }
    }
    
    func url(forMethod method: String, parameters: inout [AnyHashable: Any]?) -> String? {
        if let pattern = self.pattern(forMethod: method) {
            return url(withPattern: pattern, parameters: &parameters)
        }
        return url(forMethodWithoutItem: method)
    }
    
    func verb(forMethod method: String) -> String {
        if let item = dict[method] {
            return (item as! ALRESTContractItem).verb
        }
        return ALRESTContractDefaultVerb
    }
    
    func multipart(forMethod method: String) -> Bool {
        if let item = dict[method] {
            return (item as! ALRESTContractItem).multipart
        }
        return false
    }
    
    func url(forMethodWithoutItem method: String) -> String {
        return method.replacingOccurrences(of: ".", with: "/")
    }
    
    func pattern(forMethod method: String) -> String? {
        if let item = dict[method] {
            return (item as! ALRESTContractItem).pattern
        }
        return nil
    }
    
    func url(withPattern pattern: String, parameters: inout [AnyHashable: Any]?) -> String? {
        if parameters == nil {
            return pattern
        }
        var url = pattern
        for key:AnyHashable in parameters!.keys {
            // create a copy of allKeys to mutate parameters
            let keyPattern = ":\(key as? String ?? "")"
            if Int((url as NSString?)?.range(of: keyPattern).location ?? 0) == NSNotFound {
                continue
            }
            let valueStr = parameters![key] as! String
            url = url.replacingOccurrences(of: keyPattern, with: valueStr)
            parameters!.removeValue(forKey: key)
        }
        return url
    }
}
