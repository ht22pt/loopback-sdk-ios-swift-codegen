//
//  ALBookStruct.swift
//  demo
//
//  Created by Technologies Generator Tools on 26/07/2018.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

class ALBookStruct: ALBaseStruct {

  var _title: String
  var _author: String
  var _data: String
  var _totalPages: NSNumber 
  var _hardcover: Bool 
  var _keywords: [Any]
  var _addressId: NSNumber 
  
  required init(data: JSON) {
    self._title = data["title"].string ?? ""
    self._author = data["author"].string ?? ""
    self._data = data["data"].string ?? ""
    self._totalPages = data["totalPages"].number  ?? 0
    self._hardcover = data["hardcover"].bool  ?? false
    self._keywords = data["keywords"].array ?? [Any]()
    self._addressId = data["addressId"].number  ?? 0
 
    super.init(data: data)
  }

  func toDictionary() -> [AnyHashable:Any] {
    let data:[AnyHashable:Any] = [
      "title": self._title,
      "author": self._author,
      "data": self._data,
      "totalPages": self._totalPages,
      "hardcover": self._hardcover,
      "keywords": self._keywords,
      "addressId": self._addressId
    ]
    return data
  }

}
