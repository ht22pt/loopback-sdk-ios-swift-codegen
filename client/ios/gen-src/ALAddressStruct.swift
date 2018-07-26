//
//  ALAddressStruct.swift
//  demo
//
//  Created by Technologies Generator Tools on 26/07/2018.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

class ALAddressStruct: ALBaseStruct {

  var _district: String
  var _house_number: String
  var _more_info: String
  
  required init(data: JSON) {
    self._district = data["district"].string ?? ""
    self._house_number = data["house_number"].string ?? ""
    self._more_info = data["more_info"].string ?? ""
 
    super.init(data: data)
  }

  func toDictionary() -> [AnyHashable:Any] {
    let data:[AnyHashable:Any] = [
      "district": self._district,
      "house_number": self._house_number,
      "more_info": self._more_info
    ]
    return data
  }

}
