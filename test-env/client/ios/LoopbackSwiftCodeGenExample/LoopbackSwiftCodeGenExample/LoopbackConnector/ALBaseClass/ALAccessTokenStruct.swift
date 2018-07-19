//
//  ALAccessToken.swift
//  loopback-sdk-ios-swift-codegen
//
//  Created by MacPro on 7/2/18.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

class ALAccessTokenStruct: ALBaseStruct {
    var userId:String
    
    required init(data:JSON) {
        self.userId = data["userId"].string ?? ""
        super.init(data: data)
    }
}
