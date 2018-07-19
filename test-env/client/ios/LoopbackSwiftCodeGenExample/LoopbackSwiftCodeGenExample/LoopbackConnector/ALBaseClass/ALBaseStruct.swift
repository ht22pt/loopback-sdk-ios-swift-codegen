//
//  ALBaseStruct.swift
//  loopback-sdk-ios-swift-codegen
//
//  Created by MacPro on 7/3/18.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

class ALBaseStruct: NSObject {
    var id:String = ""
    var jsonData:JSON?
    
    required init(data:JSON) {
        // Empty Interface
        super.init()
        self.id = data["id"].string ?? ""
        self.jsonData = data
    }
}
