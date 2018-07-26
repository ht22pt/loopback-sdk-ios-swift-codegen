//
//  ALBaseModelClass.swift
//  loopback-sdk-ios-swift-codegen
//
//  Created by MacPro on 7/2/18.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

class ALUserStruct: ALBaseStruct {
    var email:String
    var password:String
    var realm:String?
    var emailVerified:NSNumber
    var status:String
    
    required init(data:JSON) {
        self.email = data["email"].string ?? ""
        self.password = data["password"].string ?? ""
        self.realm = data["realm"].string
        self.emailVerified = data["emailVerified"].number ?? 0
        self.status = data["status"].string ?? ""
        super.init(data: data)
    }
    
    func toDictionary() -> [AnyHashable:Any] {
        let data:[AnyHashable:Any] = [
            "email": self.email,
            "password": self.password,
            "realm": self.realm,
            "emailVerified": self.emailVerified,
            "status": self.status,
        ]
        return data
    }
}
