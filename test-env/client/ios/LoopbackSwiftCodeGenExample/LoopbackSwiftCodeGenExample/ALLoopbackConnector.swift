//
//  ALLoobackConnector.swift
//  LoopbackSwiftCodeGenExample
//
//  Created by MacPro on 7/19/18.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import UIKit

class ALLoopbackConnector {
    let appDelegate:AppDelegate? = (UIApplication.shared.delegate as! AppDelegate?)
    
    // AL Loopback Repo
    var adapter: AlamofireLBAdapter
    var connectError = false
    
    static let sharedInstance = ALLoopbackConnector()
    
    private init() {
        
        // Read configuration from Utility
        let defaultConnection:String = "http://127.0.0.1:3000/api"
        
        self.adapter = AlamofireLBAdapter(url: URL(string:defaultConnection)!, allowsInvalidSSLCertificate: true)
        
        // MARK: Load list model repo api here
    }
    
    func checkConnection() -> Bool {
        return self.adapter.connected
    }
    
    func updateAccessToken(token:String) {
        self.adapter.accessToken = token
    }
    
    func clearToken() {
        self.adapter.accessToken = ""
    }
}
