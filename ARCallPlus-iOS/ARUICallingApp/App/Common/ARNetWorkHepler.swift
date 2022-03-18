//
//  ARNetWorkHepler.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/2/24.
//

import UIKit
import Alamofire
import SwiftyJSON

//private let requestUrl = "http://192.168.1.111:23680/api/v1/"
private let requestUrl = "https://pro.gateway.agrtc.cn/api/v1/"

private var authorization: String?

class ARNetWorkHepler: NSObject {
    class func getResponseData(_ url: String, parameters: [String: AnyObject]? = nil, headers: Bool, success:@escaping(_ result: JSON)-> Void, error:@escaping (_ error: NSInteger)->Void) {
        let resultUrl = requestUrl + url
        let urls = NSURL(string: resultUrl as String)
        var request = URLRequest(url: urls! as URL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        if headers {
            request.setValue(authorization, forHTTPHeaderField: "AR-Authorization")
        }
        
        if parameters != nil {
            let data = try! JSONSerialization.data(withJSONObject: parameters!, options: JSONSerialization.WritingOptions.prettyPrinted)

            let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            if let json = json {
                print(json)
            }
            request.httpBody = json!.data(using: String.Encoding.utf8.rawValue)
        }
        
        let alamoRequest = Alamofire.request(request as URLRequestConvertible)
        alamoRequest.validate(statusCode: 200..<300)
        alamoRequest.responseString { response in
            print(response)
            if let jsonData = response.result.value {
                let headJson = JSON(response.response?.allHeaderFields as Any)
                if let token = headJson["Ar-Token"].string {
                    authorization = token
                }
                success(JSON(parseJSON: jsonData))
            } else if let er = response.result.error {
                let errorResult = er as NSError
                let code = response.response?.statusCode ?? errorResult.code
                error(code)
                print("Calling  Response -  \(code)")
            }
        }
    }
}
