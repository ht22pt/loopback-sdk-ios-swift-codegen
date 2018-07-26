//
//  ALBookRepository.swift
//  demo
//
//  Created by Technologies Generator Tools on 26/07/2018.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

class ALBookRepository: ALBaseModel {
  convenience required init() {
    self.init(className: "Book", prefix: "AL", postfix: "Struct")
    self.repository(with: "Books")
  }

  func modelWithJson(data:JSON) -> ALBookStruct {
    return ALBookStruct(data: data)
  }

  func modelAddressWithJson(data:JSON) -> ALAddressStruct {
    return ALAddressStruct(data: data)
  }

  override func contract() -> ALRESTContract? {
    let contract:ALRESTContract? = super.contract()

    contract?.add(ALRESTContractItem(pattern: "/\(className)/", verb: "POST"), forMethod: "\(className).create")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/", verb: "PATCH"), forMethod: "\(className).patchOrCreate")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/replaceOrCreate", verb: "POST"), forMethod: "\(className).replaceOrCreate")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/upsertWithWhere", verb: "POST"), forMethod: "\(className).upsertWithWhere")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/:id/exists", verb: "GET"), forMethod: "\(className).exists")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/:id", verb: "GET"), forMethod: "\(className).findById")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/:id/replace", verb: "POST"), forMethod: "\(className).replaceById")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/", verb: "GET"), forMethod: "\(className).find")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/findOne", verb: "GET"), forMethod: "\(className).findOne")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/update", verb: "POST"), forMethod: "\(className).updateAll")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/:id", verb: "DEL"), forMethod: "\(className).deleteById")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/:id/testNumberMethod", verb: "POST"), forMethod: "\(className).testNumberMethod")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/:id/String", verb: "POST"), forMethod: "\(className).testStringMethod")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/:id/testBoolMethod", verb: "GET"), forMethod: "\(className).testBoolMethod")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/:id/testArrayMethod", verb: "PUT"), forMethod: "\(className).testArrayMethod")
    contract?.add(ALRESTContractItem(pattern: "/\(className)/:id/testObjectMethod", verb: "POST"), forMethod: "\(className).testObjectMethod")
    return contract
  }


  func create(with data:ALBookStruct
    ,success: @escaping (ALBookStruct) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("create",
      parameters: [ : ],
      bodyParameters: data.toDictionary(), 
      success: { value in
      }, failure: failure)
  }

  func patchOrCreate(with data:ALBookStruct
    ,success: @escaping (ALBookStruct) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("patchOrCreate",
      parameters: [ : ],
      bodyParameters: data.toDictionary(), 
      success: { value in
      }, failure: failure)
  }

  func replaceOrCreate(with data:ALBookStruct
    ,success: @escaping (ALBookStruct) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("replaceOrCreate",
      parameters: [ : ],
      bodyParameters: data.toDictionary(), 
      success: { value in
      }, failure: failure)
  }

  func upsert(with data:ALBookStruct
    ,success: @escaping (ALBookStruct) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("upsertWithWhere",
      parameters: [ : ],
      bodyParameters: data.toDictionary(), 
      success: { value in
      }, failure: failure)
  }

  func upsert(with filterWhere:[AnyHashable:Any], data:ALBookStruct
    ,success: @escaping (ALBookStruct) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("upsertWithWhere",
      parameters: [ "where": filterWhere ],
      bodyParameters: data.toDictionary(), 
      success: { value in
      }, failure: failure)
  }

  func exists(with id:Any
    ,success: @escaping (Bool) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("exists",
      parameters: [ "id": id ],
      success: { value in
        // Return bool data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success((value as! SwiftyJSON.JSON)["exists"].bool!)
      }, failure: failure)
  }

  func find(by id:Any
    ,success: @escaping (ALBookStruct) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("findById",
      parameters: [ "id": id ],
      success: { value in
      }, failure: failure)
  }

  func find(by id:Any, filter:[AnyHashable:Any]
    ,success: @escaping (ALBookStruct) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("findById",
      parameters: [ "id": id, "filter": filter ],
      success: { value in
      }, failure: failure)
  }

  func replace(by id:Any, data:ALBookStruct
    ,success: @escaping (ALBookStruct) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("replaceById",
      parameters: [ "id": id ],
      bodyParameters: data.toDictionary(), 
      success: { value in
      }, failure: failure)
  }

  func find(with success: @escaping ([SwiftyJSON.JSON]) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("find",
      parameters: [ : ],
      success: { value in
        // Return array object data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        var models = [SwiftyJSON.JSON]()
        if let arrayData = (value as! SwiftyJSON.JSON).array {
            for row in arrayData {
                models.append(row)
            }
        }
        success(models)
      }, failure: failure)
  }

  func find(with filter:[AnyHashable:Any]
    ,success: @escaping ([SwiftyJSON.JSON]) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("find",
      parameters: [ "filter": filter ],
      success: { value in
        // Return array object data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        var models = [SwiftyJSON.JSON]()
        if let arrayData = (value as! SwiftyJSON.JSON).array {
            for row in arrayData {
                models.append(row)
            }
        }
        success(models)
      }, failure: failure)
  }

  func findOne(with success: @escaping (ALBookStruct) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("findOne",
      parameters: [ : ],
      success: { value in
      }, failure: failure)
  }

  func findOne(with filter:[AnyHashable:Any]
    ,success: @escaping (ALBookStruct) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("findOne",
      parameters: [ "filter": filter ],
      success: { value in
      }, failure: failure)
  }

  func updateAll(with data:ALBookStruct
    ,success: @escaping (NSNumber) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("updateAll",
      parameters: [ : ],
      bodyParameters: data.toDictionary(), 
      success: { value in
        // Return number data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success((value as! SwiftyJSON.JSON)["info"].number!)
      }, failure: failure)
  }

  func updateAll(with filterWhere:[AnyHashable:Any], data:ALBookStruct
    ,success: @escaping (NSNumber) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("updateAll",
      parameters: [ "where": filterWhere ],
      bodyParameters: data.toDictionary(), 
      success: { value in
        // Return number data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success((value as! SwiftyJSON.JSON)["info"].number!)
      }, failure: failure)
  }

  func delete(by id:Any
    ,success: @escaping (SwiftyJSON.JSON) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("deleteById",
      parameters: [ "id": id ],
      success: { value in
        // Return object data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(value as! SwiftyJSON.JSON)
      }, failure: failure)
  }

  func testNumberMethod(with id:String, keywords:NSNumber
    ,success: @escaping (NSNumber) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("testNumberMethod",
      parameters: [ "id": id, "keywords": keywords ],
      success: { value in
        // Return number data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success((value as! SwiftyJSON.JSON)["body"].number!)
      }, failure: failure)
  }

  func testStringMethod(with id:String, keywords:String
    ,success: @escaping (String) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("testStringMethod",
      parameters: [ "id": id, "keywords": keywords ],
      success: { value in
        // Return string data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success((value as! SwiftyJSON.JSON)["body"].string!)
      }, failure: failure)
  }

  func testBoolMethod(with id:String, keywords:NSNumber
    ,success: @escaping (Bool) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("testBoolMethod",
      parameters: [ "id": id, "keywords": keywords ],
      success: { value in
        // Return bool data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success((value as! SwiftyJSON.JSON)["body"].bool!)
      }, failure: failure)
  }

  func testArrayMethod(with id:String, keywords:Any
    ,success: @escaping ([SwiftyJSON.JSON]) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("testArrayMethod",
      parameters: [ "id": id, "keywords": keywords ],
      success: { value in
        // Return array object data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        var models = [SwiftyJSON.JSON]()
        if let arrayData = (value as! SwiftyJSON.JSON).array {
            for row in arrayData {
                models.append(row)
            }
        }
        success(models)
      }, failure: failure)
  }

  func testObjectMethod(with id:String, keywords:[AnyHashable:Any]
    ,success: @escaping (SwiftyJSON.JSON) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("testObjectMethod",
      parameters: [ "id": id, "keywords": keywords ],
      success: { value in
        // Return object data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(value as! SwiftyJSON.JSON)
      }, failure: failure)
  }
}
