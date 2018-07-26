//
//  AlamofireLBAdapter.swift
//  loopback-sdk-ios-swift-codegen
//
//  Created by MacPro on 6/6/18.
//  Copyright © 2018 Arrive Technologies. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let AdapterNotConnectedErrorDescription = "Adapter not connected."

/**
 * Blocks of this type are executed for any successful method invocation, i.e.
 * one where the remote method called the callback as `callback(null, value)`.
 *
 * **Example:**
 * @code
 * [...
 *     success:^(id value) {
 *         NSLog(@"The result was: %@", value);
 *     }
 * ...];
 * @endcode
 *
 * @param value  The top-level value returned by the remote method, typed
 *               appropriately: an NSNumber for all Numbers, an
 *               NSDictionary for all Objects, etc.
 */
typealias ALSuccessBlock = (Any?) -> Void

/**
 * Blocks of this type are executed for any failed method invocation, i.e. one
 * where the remote method called the callback as `callback(error, null)` or
 * just `callback(error)`.
 *
 * **Example:**
 * @code
 * [...
 *     success:^(id value) {
 *         NSLog(@"The result was: %@", value);
 *     }
 * ...];
 * @endcode
 *
 * @param error  The error received, as a properly-formatted
 *               NSError.
 */
typealias ALFailureBlock = (Error?) -> Void

enum HTTPClientParameterEncoding : Int {
    case FormURLParameterEncoding
    case JsonParameterEncoding
    case PropertyListParameterEncoding
}

class QueryStringPair {
    var field: String
    var value: Any
    
    init(field: String, value: Any) {
        self.field = field
        self.value = value
    }
    
    func urlEncodedStringValue(with stringEncoding: String.Encoding) -> String? {
        if self.value is NSNull {
            return self.field.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        }
        let key:String? = self.field.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let value:String? = (self.value as AnyObject).description.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        return "\(key!)=\(value!)"
    }
}

class AlamofireLBAdapter {
    
    /** YES if the SLAdapter is connected to a server, NO otherwise. */
    public private(set) var connected:Bool = false
    
    /** A flag to control if invalid SSL certificates are allowed */
    public private(set) var allowsInvalidSSLCertificate:Bool = false
    
    /** A custom contract for fine-grained route configuration. */
    var contract: ALRESTContract!
    
    private var baseUrl:URL
    private var clientEncoding:HTTPClientParameterEncoding = .JsonParameterEncoding
    private var stringEncoding:String.Encoding = String.Encoding.utf8
    private var clientHeaders:[String:String] = [String:String]()
    
    /** Set the given access token in the header for all RESTful interaction. */
    var accessToken: String! {
        didSet {
            self.setDefaultHeader("Authorization", value: self.accessToken)
        }
    }
    
    init(url:URL) {
        self.baseUrl = url
        self.contract = ALRESTContract()
        self.connect(to: self.baseUrl)
    }
    
    init(url:URL, allowsInvalidSSLCertificate:Bool) {
        self.baseUrl = url
        self.allowsInvalidSSLCertificate = allowsInvalidSSLCertificate
        self.contract = ALRESTContract()
        self.connect(to: self.baseUrl)
    }
    
    private func connect(to url: URL) {
        // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
        if (url.path.count ) > 0 && !url.absoluteString.hasSuffix("/") {
            self.baseUrl = url.appendingPathComponent("/")
        }
        self.connected = true
        self.clientEncoding = .JsonParameterEncoding
        self.setDefaultHeader("Accept", value: "application/json")
    }
    
    private func setDefaultHeader(_ name:String, value:String) {
        self.clientHeaders.updateValue(value, forKey: name)
    }
    
    func initModel() {
        // Init model name
        // Copy Adapter to model
        // Function model call by adapter
    }
    
    private func queryStringPairsFromDictionary(dictionary: Any) -> [QueryStringPair] {
        return queryStringPairsFromKeyAndValue(key: nil, value: dictionary)
    }
    
    private func queryStringPairsFromKeyAndValue(key: String?, value: Any) -> [QueryStringPair] {
        var mutableQueryStringComponents = [QueryStringPair]()
        
        if (value is [AnyHashable: Any]) {
            let dictionary:[AnyHashable: Any] = value as! [AnyHashable: Any]
            // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
            for nestedKey:AnyHashable in dictionary.keys.sorted(by: { $0.description < $1.description }) {
                if let nestedValue = dictionary[nestedKey] {
                    let keyData:String = key != nil ? "\(key!)[\(nestedKey)]" : nestedKey as! String
                    mutableQueryStringComponents.append(contentsOf: queryStringPairsFromKeyAndValue(key: keyData, value: nestedValue))
                }
            }
        } else if (value is [Any]) {
            if let array:[Any] = value as? [Any] {
                for nestedValue:Any in array {
                    mutableQueryStringComponents.append(contentsOf: queryStringPairsFromKeyAndValue(key: "\(key!)[]", value: nestedValue))
                }
            }
        } else if (value is Set<AnyHashable>) {
            if let setData = value as? Set<AnyHashable> {
                for obj:Any in setData {
                    mutableQueryStringComponents.append(contentsOf: queryStringPairsFromKeyAndValue(key: key, value: obj))
                }
            }
        } else {
            mutableQueryStringComponents.append(QueryStringPair(field: key!, value: value))
        }
        return mutableQueryStringComponents
    }
    
    private func queryStringFromParametersWithEncoding(parameters: [AnyHashable:Any]?, stringEncoding: String.Encoding) -> String? {
        var mutablePairs = [String]()
        for pair: QueryStringPair in self.queryStringPairsFromDictionary(dictionary: parameters!) {
            if let anEncoding = pair.urlEncodedStringValue(with: stringEncoding) {
                mutablePairs.append(anEncoding)
            }
        }
        return mutablePairs.joined(separator: "&")
    }
    
    /// Init Repository with class name
    ///
    /// - Parameter type: class name
    /// - Returns: a object Repository
    /// - Throws: exception when no any Repository match with class name
    func repository(with type: AnyClass) throws -> ALBaseModel {
        if !type.isSubclass(of: ALBaseModel.self) {
            throw NSException(name: .invalidArgumentException, reason: "Argument needs to be a subclass of ALBaseModel", userInfo: nil) as! Error
        }
        let repository:ALBaseModel = (type as! ALBaseModel.Type).init()
        attach(repository)
        return repository
    }
    
    func attach(_ repository: ALBaseModel) {
        self.contract.addItems(from: (repository.contract())!)
        repository.adapter = self
    }
    
    private func makeRequest(withMethod method: String, path: String?, parameters: [AnyHashable:Any]?) -> URLRequest {
        var url:URL = URL(string: path ?? "", relativeTo: self.baseUrl)!
        var request:URLRequest = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = self.clientHeaders
        if parameters != nil {
            if (method == "GET") || (method == "HEAD") || (method == "DELETE") {
                let fullUrl:String = url.absoluteString
                let queryString:String = self.queryStringFromParametersWithEncoding(parameters: parameters, stringEncoding: stringEncoding)!
                let urlWithQuery:String = "\(fullUrl)\((path?.contains("?"))! ? "&\(queryString)" : "?\(queryString)")"
                url = URL(string: urlWithQuery)!
                request.url = url
            } else {
                // Action POST
                let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(stringEncoding.rawValue)) as String?
                let error: Error? = nil
                switch self.clientEncoding {
                case .FormURLParameterEncoding:
                    request.setValue("application/x-www-form-urlencoded; charset=\(charset ?? "")", forHTTPHeaderField: "Content-Type")
                    request.httpBody = self.queryStringFromParametersWithEncoding(parameters: parameters, stringEncoding: stringEncoding)?.data(using: stringEncoding)
                case .JsonParameterEncoding:
                    request.setValue("application/json; charset=\(charset ?? "")", forHTTPHeaderField: "Content-Type")
                    if let aParameters = parameters {
                        request.httpBody = try? JSONSerialization.data(withJSONObject: aParameters, options: [])
                    }
                case .PropertyListParameterEncoding:
                    request.setValue("application/x-plist; charset=\(charset ?? "")", forHTTPHeaderField: "Content-Type")
                    if let aParameters = parameters {
                        request.httpBody = try? PropertyListSerialization.data(fromPropertyList: aParameters, format: .xml, options: 0)
                    }
                }
                if error != nil {
                    if let anError = error {
                        print("\(type(of: self)) \(NSStringFromSelector(#function)): \(anError)")
                    }
                }
            }
        }
        return request
    }

    private func request(withPath path: String,
                verb: String,
                parameters: [AnyHashable: Any]?,
                bodyParameters: [AnyHashable: Any]?,
                success: @escaping ALSuccessBlock,
                failure: @escaping ALFailureBlock)
    {
        var fullPath:String = "\(self.baseUrl.absoluteString)\(path)"
        let _parameters = (parameters?.count ?? 0 > 0) ? parameters : nil
        assert(connected, AdapterNotConnectedErrorDescription)
        // Remove the leading / so that the path is treated as relative to the baseURL
        if fullPath.hasPrefix("/") {
            fullPath = String(path[path.startIndex...])
        }
        var request: URLRequest
        if (verb == "GET") || (verb == "HEAD") || (verb == "DELETE") {
            request = self.makeRequest(withMethod: verb, path: fullPath, parameters: _parameters)
        } else {
            self.clientEncoding = .JsonParameterEncoding
            request = self.makeRequest(withMethod: verb, path: fullPath, parameters: bodyParameters)
            if _parameters != nil {
                let queryStr:String = self.queryStringFromParametersWithEncoding(parameters: _parameters, stringEncoding: self.stringEncoding) ?? ""
                let url = URL(string: request.url?.absoluteString ?? "" + ("?\(queryStr)"))
                request.url = url
            }
        }
        
        // Make client request and send to server
        Alamofire.request(request)
            .responseJSON { response in
                switch response.result {
                case .success:
                    let retData = try! JSON(data: response.data!)
                    if let error = retData["error"].dictionary {
                        let code:Int = (error["status"]?.intValue)!
                        let message:String = (error["message"]?.stringValue)!
                        let error = NSError(domain: message, code: code, userInfo:nil)
                        failure(error)
                        return
                    }
                    success(retData)
                    break
                case .failure(let error):
                    failure(error)
                    break
                }
        }
    }
    
    func invokeStaticMethod(_ method: String?, parameters: inout [AnyHashable: Any]?, success: @escaping ALSuccessBlock, failure: @escaping ALFailureBlock) {
        self.invokeStaticMethod(method, parameters: &parameters, bodyParameters: nil, success: success, failure: failure)
    }
    
    func invokeStaticMethod(_ method: String?, parameters: inout [AnyHashable: Any]?, bodyParameters:[AnyHashable: Any]?, success: @escaping ALSuccessBlock, failure: @escaping ALFailureBlock) {
        assert((self.contract != nil), "Invalid contract.")
        let verb = self.contract!.verb(forMethod: method!)
        let path = self.contract!.url(forMethod: method!, parameters: &parameters)
        self.request(withPath: path!, verb: verb, parameters: parameters, bodyParameters: bodyParameters, success: success, failure: failure)
    }
    
    func invokeInstanceMethod(_ method: String?, constructorParameters: [AnyHashable: Any]?, parameters: [AnyHashable: Any]?, success: @escaping ALSuccessBlock, failure: @escaping ALFailureBlock) {
        self.invokeInstanceMethod(method, constructorParameters: constructorParameters, parameters: parameters, bodyParameters: nil, success: success, failure: failure)
    }
    
    func invokeInstanceMethod(_ method: String?, constructorParameters: [AnyHashable: Any]?, parameters: [AnyHashable: Any]?, bodyParameters: [AnyHashable: Any]?, success: @escaping ALSuccessBlock, failure: @escaping ALFailureBlock) {
        // TODO(schoon) - Break out and document error description.
         assert((self.contract != nil), "Invalid contract.")
        var combinedParameters:[AnyHashable: Any]? = [AnyHashable: Any]()
        for (k, v) in constructorParameters! { combinedParameters![k] = v }
        for (k, v) in parameters! { combinedParameters![k] = v }
        let verb = contract?.verb(forMethod: method!)
        let path = contract?.url(forMethod: method!, parameters: &combinedParameters)
        request(withPath: path!, verb: verb!, parameters: combinedParameters, bodyParameters: bodyParameters, success: success, failure: failure)
    }
}
