//
//  ALBaseModel.swift
//  loopback-sdk-ios-swift-codegen
//
//  Created by MacPro on 6/8/18.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation

typealias ALBaseModelFindALSuccessBlock = (ALBaseModel?) -> Void
typealias ALBaseModelFindOneALSuccessBlock = (ALBaseModel?) -> Void
typealias ALBaseModelAllALSuccessBlock = ([Any]?) -> Void

extension Array {
    func enumerateWithIndex(block: (_ item: Element, _ index: Int)->Void) {
        let fullRange = startIndex..<endIndex
        for x in fullRange {
            block(self[x], x)
        }
    }
}

class ALBaseModel: ALModelRepository {
    
    internal var _id:String?
    internal var adapter:AlamofireLBAdapter?
    
    convenience required override init() {
        self.init(className: "BaseModel", prefix: "", postfix: "")
        self.repository(with: "BaseModel")
    }
    
    override func contract() -> ALRESTContract? {
        self._contract = super.contract()
        self._contract!.add(ALRESTContractItem(pattern: "/\(className)", verb: "POST"), forMethod: "\(className).prototype.create")
        self._contract!.add(ALRESTContractItem(pattern: "/\(className)/:id", verb: "PUT"), forMethod: "\(className).prototype.save")
        self._contract!.add(ALRESTContractItem(pattern: "/\(className)/:id", verb: "DELETE"), forMethod: "\(className).prototype.remove")
        self._contract!.add(ALRESTContractItem(pattern: "/\(className)/:id", verb: "GET"), forMethod: "\(className).findById")
        self._contract!.add(ALRESTContractItem(pattern: "/\(className)", verb: "GET"), forMethod: "\(className).all")
        self._contract!.add(ALRESTContractItem(pattern: "/\(className)", verb: "GET"), forMethod: "\(className).find")
        self._contract!.add(ALRESTContractItem(pattern: "/\(className)/findOne", verb: "GET"), forMethod: "\(className).findOne")
        
        return self._contract
    }
    
    func find(byId _id: Any, success: @escaping ALBaseModelFindALSuccessBlock, failure: @escaping ALFailureBlock) {
        invokeStaticMethod("findById", parameters: ["id": _id], success: { value in
            if let aValue = value {
                // TODO: Need implement convert json data to model
                success(aValue as? ALBaseModel)
            } else {
                success(nil)
            }
        }, failure: failure)
    }
    
    func all(withSuccess success: @escaping ALBaseModelAllALSuccessBlock, failure: @escaping ALFailureBlock) {
        invokeStaticMethod("all", parameters: nil, success: { value in
            if let aValue = value {
                // TODO: Check format value
                // assert(value.self.isSubclass(of: [Any].self) ?? false, "Received non-Array: \(aValue)")
                var models = [Any]()
                for item in (aValue as! Array<Any>) {
                     models.append(item)
                }
                success(models)
            } else {
                success(nil)
            }
        }, failure: failure)
    }
    
    func findOne(withFilter filter: [AnyHashable: Any], success: @escaping ALBaseModelFindOneALSuccessBlock, failure: @escaping ALFailureBlock) {
        invokeStaticMethod("findOne", parameters: ["filter": filter], success: { value in
            if let aValue = value {
                // TODO: Need implement convert json data to model
                success(aValue as? ALBaseModel)
            } else {
                success(nil)
            }
        }, failure: failure)
    }
    
    func find(withFilter filter: [AnyHashable: Any], success: @escaping ALBaseModelAllALSuccessBlock, failure: @escaping ALFailureBlock) {
        invokeStaticMethod("find", parameters: ["filter": filter], success: { value in
            if let aValue = value {
                var models = [Any]()
                for item in (aValue as! Array<Any>) {
                    models.append(item)
                }
                success(models)
            } else {
                success(nil)
            }
        }, failure: failure)
    }
    
    internal func repository(with className:String) {
        self.className = className
    }
    
    internal func invokeStaticMethod(_ name: String, parameters: [AnyHashable: Any]?, bodyParameters: [AnyHashable: Any]?, success: @escaping ALSuccessBlock, failure: @escaping ALFailureBlock) {
        let path = "\(className).\(name)"
        var formatParameters = parameters
        self.adapter?.invokeStaticMethod(path, parameters: &formatParameters, bodyParameters: self.convertProperties(bodyParameters), success: success, failure: failure)
    }
    
    internal func invokeStaticMethod(_ name: String, parameters: [AnyHashable: Any]?, success: @escaping ALSuccessBlock, failure: @escaping ALFailureBlock) {
        let path = "\(className).\(name)"
        var formatParameters = self.convertArguments(parameters)
        self.adapter?.invokeStaticMethod(path, parameters: &formatParameters, bodyParameters: nil, success: success, failure: failure)
    }

}
