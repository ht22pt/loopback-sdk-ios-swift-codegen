//
//  ALBookRepository.swift
//  demo
//
//  Created by Technologies Generator Tools on 19/07/2018.
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

    contract?.add(ALRESTContractItem(pattern: "/\(className)/:id/address", verb: "GET"), forMethod: "\(className).get__address")
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
    contract?.add(ALRESTContractItem(pattern: "/\(className)/count", verb: "GET"), forMethod: "\(className).count")
    return contract
  }


  func get__address(with id:id
    ,success: @escaping (Address) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("get__address",
      parameters: [ id: id ],
      success: { value in
        // Return model type
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(self.modelAddressWithJson(data: value as! SwiftyJSON.JSON))
      }, failure: failure)
    )
  }

  func get__address(with id:id, refresh:NSNumber
    ,success: @escaping (Address) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("get__address",
      parameters: [ id: id, refresh: refresh ],
      success: { value in
        // Return model type
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(self.modelAddressWithJson(data: value as! SwiftyJSON.JSON))
      }, failure: failure)
    )
  }

  func create(with data:Book
    ,success: @escaping (Book) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("create",
      parameters: [  ],
      bodyParameters: data.toDictionary(), 
      success: { value in
        // Return model type
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(self.modelWithJson(data: value as! SwiftyJSON.JSON))
      }, failure: failure)
    )
  }

  func patchOrCreate(with data:Book
    ,success: @escaping (Book) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("patchOrCreate",
      parameters: [  ],
      bodyParameters: data.toDictionary(), 
      success: { value in
        // Return model type
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(self.modelWithJson(data: value as! SwiftyJSON.JSON))
      }, failure: failure)
    )
  }

  func replaceOrCreate(with data:Book
    ,success: @escaping (Book) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("replaceOrCreate",
      parameters: [  ],
      bodyParameters: data.toDictionary(), 
      success: { value in
        // Return model type
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(self.modelWithJson(data: value as! SwiftyJSON.JSON))
      }, failure: failure)
    )
  }

  func upsert(with data:Book
    ,success: @escaping (Book) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("upsertWithWhere",
      parameters: [  ],
      bodyParameters: data.toDictionary(), 
      success: { value in
        // Return model type
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(self.modelWithJson(data: value as! SwiftyJSON.JSON))
      }, failure: failure)
    )
  }

  func upsert(with where:[AnyHashable:Any], data:Book
    ,success: @escaping (Book) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("upsertWithWhere",
      parameters: [ where: where ],
      bodyParameters: data.toDictionary(), 
      success: { value in
        // Return model type
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(self.modelWithJson(data: value as! SwiftyJSON.JSON))
      }, failure: failure)
    )
  }

  func exists(with id:id
    ,success: @escaping (BOOL) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("exists",
      parameters: [ id: id ],
      success: { value in
      }, failure: failure)
    )
  }

  func find(by id:id
    ,success: @escaping (Book) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("findById",
      parameters: [ id: id ],
      success: { value in
        // Return model type
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(self.modelWithJson(data: value as! SwiftyJSON.JSON))
      }, failure: failure)
    )
  }

  func find(by id:id, filter:[AnyHashable:Any]
    ,success: @escaping (Book) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("findById",
      parameters: [ id: id, filter: filter ],
      success: { value in
        // Return model type
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(self.modelWithJson(data: value as! SwiftyJSON.JSON))
      }, failure: failure)
    )
  }

  func replace(by id:id, data:Book
    ,success: @escaping (Book) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("replaceById",
      parameters: [ id: id ],
      bodyParameters: data.toDictionary(), 
      success: { value in
        // Return model type
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(self.modelWithJson(data: value as! SwiftyJSON.JSON))
      }, failure: failure)
    )
  }

  func find(with success: @escaping ([SwiftyJSON.JSON]) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("find",
      parameters: [  ],
      success: { value in
      }, failure: failure)
    )
  }

  func find(with filter:[AnyHashable:Any]
    ,success: @escaping ([SwiftyJSON.JSON]) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("find",
      parameters: [ filter: filter ],
      success: { value in
      }, failure: failure)
    )
  }

  func findOne(with success: @escaping (Book) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("findOne",
      parameters: [  ],
      success: { value in
        // Return model type
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(self.modelWithJson(data: value as! SwiftyJSON.JSON))
      }, failure: failure)
    )
  }

  func findOne(with filter:[AnyHashable:Any]
    ,success: @escaping (Book) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("findOne",
      parameters: [ filter: filter ],
      success: { value in
        // Return model type
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success(self.modelWithJson(data: value as! SwiftyJSON.JSON))
      }, failure: failure)
    )
  }

  func updateAll(with data:Book
    ,success: @escaping (NSNumber) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("updateAll",
      parameters: [  ],
      bodyParameters: data.toDictionary(), 
      success: { value in
        // Return number data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success((value as! SwiftyJSON.JSON)["updateAll"].number)
      }, failure: failure)
    )
  }

  func updateAll(with where:[AnyHashable:Any], data:Book
    ,success: @escaping (NSNumber) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("updateAll",
      parameters: [ where: where ],
      bodyParameters: data.toDictionary(), 
      success: { value in
        // Return number data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success((value as! SwiftyJSON.JSON)["updateAll"].number)
      }, failure: failure)
    )
  }

  func delete(by id:id
    ,success: @escaping (SwiftyJSON.JSON) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("deleteById",
      parameters: [ id: id ],
      success: { value in
      }, failure: failure)
    )
  }

  func count(with success: @escaping (NSNumber) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("count",
      parameters: [  ],
      success: { value in
        // Return number data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success((value as! SwiftyJSON.JSON)["count"].number)
      }, failure: failure)
    )
  }

  func count(with where:[AnyHashable:Any]
    ,success: @escaping (NSNumber) -> Void
    ,failure: @escaping ALFailureBlock) {
    invokeStaticMethod("count",
      parameters: [ where: where ],
      success: { value in
        // Return number data
        assert((value is SwiftyJSON.JSON), "Received non-Array: \(String(describing: value))")
        success((value as! SwiftyJSON.JSON)["count"].number)
      }, failure: failure)
    )
  }
}
