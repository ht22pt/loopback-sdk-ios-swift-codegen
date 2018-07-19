//
//  ALAddressStruct.swift
//  demo
//
//  Created by Technologies Generator Tools on 19/07/2018.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

class ALAddressStruct: ALBaseStruct {

  var district: String
  var house_number: String
  var more_info: String
  
  required init(data: JSON) {
    self.district = data["district"].string ?? ""
    self.house_number = data["house_number"].string ?? ""
    self.more_info = data["more_info"].string ?? ""
 
    super.init(data: data)
  }
}
