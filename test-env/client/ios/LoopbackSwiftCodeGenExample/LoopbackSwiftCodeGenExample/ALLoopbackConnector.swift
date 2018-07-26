//
//  ALLoobackConnector.swift
//  LoopbackSwiftCodeGenExample
//
//  Created by MacPro on 7/19/18.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

extension SwiftyJSON.JSON {
    public var date: Date? {
        get {
            if let str = self.string {
                return SwiftyJSON.JSON.jsonDateFormatter.date(from: str)
            }
            return nil
        }
    }
    
    private static let jsonDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        fmt.timeZone = TimeZone(secondsFromGMT: 0)
        return fmt
    }()
}

class ALLoopbackConnector {
    let appDelegate:AppDelegate? = (UIApplication.shared.delegate as! AppDelegate?)
    
    // AL Loopback Repo
    var bookRepo:ALBookRepository
    var addessRepo:ALAddressRepository
    var customUserRepo: ALCustomUserRepository
    
    var adapter: AlamofireLBAdapter
    var connectError = false
    
    static let sharedInstance = ALLoopbackConnector()
    
    private init() {
        
        // Read configuration from Utility
        let defaultConnection:String = "http://127.0.0.1:3000/api"
        
        self.adapter = AlamofireLBAdapter(url: URL(string:defaultConnection)!, allowsInvalidSSLCertificate: true)
        
        // MARK: Load list model repo api here
        self.bookRepo = try! self.adapter.repository(with: ALBookRepository.self) as! ALBookRepository
        self.addessRepo = try! self.adapter.repository(with: ALAddressRepository.self) as! ALAddressRepository
        self.customUserRepo = try! self.adapter.repository(with: ALCustomUserRepository.self) as! ALCustomUserRepository
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
