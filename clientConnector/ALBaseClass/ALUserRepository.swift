//
//  ALUserRepository.swift
//  loopback-sdk-ios-swift-codegen
//
//  Created by MacPro on 6/8/18.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias ALUserLoginSuccessBlock = (Any?) -> Void
typealias ALUserFindUserSuccessBlock = (Any?) -> Void
typealias ALUserResetSuccessBlock = (Any?) -> Void

let DEFAULTS_CURRENT_USER_ID_KEY:String = "LBUserRepositoryCurrentUserId"

class ALUserRepository: ALBaseModel {
    
    // MARK: Convert JSON to Model Data
    func modelWithJson(data:JSON) -> ALBaseStruct {
        return self.structType.init(data: data)
    }
    
    func modelAccessTokenWithJson(data:JSON) -> ALAccessTokenStruct {
        return ALAccessTokenStruct(data: data)
    }
    
    var isCurrentUserIdLoaded:Bool = false
    var _currentUserId:Any?
    var cachedCurrentUser:ALBaseModel?
    
    convenience required init() {
        self.init(className: "User", prefix: "AL", postfix: "Struct")
        self.repository(with: "User")
    }
    
    override func contract() -> ALRESTContract? {
        let contract: ALRESTContract? = super.contract()
        contract?.add(ALRESTContractItem(pattern: "/\(className)/login?include=user", verb: "POST"), forMethod: "\(className).login")
        contract?.add(ALRESTContractItem(pattern: "/\(className)/logout", verb: "POST"), forMethod: "\(className).logout")
        return contract
    }
    
    func createUser(withEmail email: String, password: String, dictionary: [AnyHashable: Any]?) -> [AnyHashable: Any] {
        var user:[AnyHashable: Any] = [AnyHashable: Any]()
        user["email"] = email
        user["password"] = password
        
        // TODO: Check dictionary for add data
        
        return user
    }
    
    func login(withEmail email: String, password: String, success: @escaping ALUserLoginSuccessBlock, failure: @escaping ALFailureBlock) {
        self.invokeStaticMethod("login", parameters: nil, bodyParameters: ["email": email, "password": password], success: { value in
            if let aValue:[AnyHashable:Any] = value as? [AnyHashable : Any] {
                self.adapter?.accessToken = aValue["id"] as! String
                self._currentUserId = aValue["userId"]
            }
            success(self.modelAccessTokenWithJson(data: value as! JSON))
        }, failure: failure)
    }
    
    func findCurrentUser(withSuccess success: @escaping ALUserFindUserSuccessBlock, failure: @escaping ALFailureBlock) {
        if currentUserId() == nil {
            success(nil)
            return
        }
        self.find(byId: (currentUserId() ??  "") as Any, success: { model in
            self.cachedCurrentUser = model
            success(model)
        }, failure: failure)
    }
    
    func logout(withSuccess success: @escaping ALUserLoginSuccessBlock, failure: @escaping SLFailureBlock) {
        invokeStaticMethod("logout", parameters: nil, success: { value in
            self.adapter?.accessToken = nil
            self._currentUserId = nil
            success(value)
        }, failure: failure)
    }
    
    func resetPassword(withEmail email: String, success: @escaping ALUserResetSuccessBlock, failure: @escaping ALFailureBlock ) {
        invokeStaticMethod("reset", parameters: nil, bodyParameters: ["email": email], success: { value in
            success(value)
        }, failure: failure)
    }
    
    func currentUserId() -> String? {
        loadCurrentUserIdIfNotLoaded()
        return _currentUserId as? String
    }
    
    internal func loadCurrentUserIdIfNotLoaded() {
        if isCurrentUserIdLoaded {
            return
        }
        isCurrentUserIdLoaded = true
        let defaults = UserDefaults.standard
        self._currentUserId = defaults.object(forKey: DEFAULTS_CURRENT_USER_ID_KEY)
    }
    
    func saveCurrentUserId() {
        let defaults = UserDefaults.standard
        defaults.set(currentUserId, forKey: DEFAULTS_CURRENT_USER_ID_KEY)
    }

}
