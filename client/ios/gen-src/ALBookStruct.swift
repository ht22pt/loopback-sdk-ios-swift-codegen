//
//  ALBookStruct.swift
//  demo
//
//  Created by Technologies Generator Tools on 19/07/2018.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

class ALBookStruct: ALBaseStruct {

  var title: String
  var author: String
  var data: String
  var totalPages: NSNumber 
  var hardcover: Bool 
  var keywords: [Any]
  var addressId: NSNumber 
  
  required init(data: JSON) {
    self.title = data["title"].string ?? ""
    self.author = data["author"].string ?? ""
    self.data = data["data"].string ?? ""
    self.totalPages = data["totalPages"].number  ?? 0
    self.hardcover = data["hardcover"].bool  ?? false
    self.keywords = data["keywords"].array ?? [Any]()
    self.addressId = data["addressId"].number  ?? 0
 
    super.init(data: data)
  }
}
