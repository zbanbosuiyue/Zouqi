//
//  WooCommerceAPI.swift
//  Zouqiba
//
//  Created by Miibox on 8/19/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import Foundation
import Alamofire
import Kanna


private let WCConsumerKey = "ck_d9416856e0192556cfb0810cb27df38647adad5b"
private let WCSecretKey = "cs_3e86cad7fd7260dd449ccd1e706e7f64a72bc15d"

/* miibox
private let WCConsumerKey = "ck_e425e5aba20cbc1ac628784e9d47c18ba7b1fcf4"
private let WCSecretKey = "ck_e425e5aba20cbc1ac628784e9d47c18ba7b1fcf4"
*/

extension UIViewController{

    
    public func getWooCommerceAPI(){
        Alamofire.request(.GET, "http://oneparty.dev.quadshot.com/wc-api/v3/products?", parameters: ["consumer_key":"ck_bf05ed05c63267d61f0875c88d7dce8cc9f32ddc", "consumer_secret":"cs_6e9ad19edad93dd2da2748e72eb8ecaa7abb097e"]).responseJSON { response in
            debugPrint(response.result.value)
            debugPrint(response.request)
            
        }
    }
    
    public func getShopifyProduct(){
        Alamofire.request(.GET, "https://29cdab026fea59770befdb2d76234529:b4676e8565059423b4a9e968302734a7@thechihuo.myshopify.com/admin/products.json?fields=id,images,title").responseJSON { response in
            let data = response.result.value as! [String: AnyObject]
            let products = data["products"]
            print(products)
            print(products!.count)
        }
    }
    
    public func sendPostToWooCommerce(){
        let product = [
            "product": [
                "title": "Premium Quality",
                "type": "simple",
                "regular_price": "21.99",
                "description": "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo.",
                "short_description": "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.",
                "categories": [
                    9,
                    14
                ],
                "images": [
                    [
                        "src": "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png",
                        "position": 0
                    ],
                    [
                        "src": "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png",
                        "position": 1
                    ]
                ]
            ]
        ]
        
        let url:NSURL = NSURL(string: "https://www.miibox.com/wp2/wc-api/v3/products?consumer_key=ck_bf05ed05c63267d61f0875c88d7dce8cc9f32ddc&consumer_secret=cs_6e9ad19edad93dd2da2748e72eb8ecaa7abb097e")!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(product, options: [])
        
        Alamofire.request(request)
            .responseJSON { response in
                // do whatever you want here
                switch response.result {
                case .Failure(let error):
                    print(error)
                case .Success(let responseObject):
                    print(responseObject)
                    print(request)
                }
        }
    }
    
    public func createWCCustomer(email: String, phone: String, pwd: String, completion:(Detail: AnyObject, Success: Bool) -> Void){
        let customerInfo = [
            "customer" : [
                "email" : email,
                "password" : pwd,
                "billing" : [
                    "phone" : phone
                ]
            ]
        ]
        
        let url:NSURL = NSURL(string: "\(BaseURL)/wc-api/v3/customers?consumer_key=\(WCConsumerKey)&consumer_secret=\(WCSecretKey)")!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(customerInfo, options: [])

        
        Alamofire.request(request)
            .responseJSON { response in
                // do whatever you want here
                switch response.result {
                case .Failure(let error):
                    completion(Detail: "Network Problem", Success: false)
                    
                case .Success(let responseObject):
                    let responseContent = responseObject as! [String : AnyObject]
                    if let errors = responseContent["errors"] as? [[String : AnyObject]]{
                        completion(Detail: errors, Success: true)
                    } else{
                        completion(Detail: "Created Customer Success", Success: true)
                    }
            }
        }
    }
    
    public func loginToWC(uname: String, pwd: String, completion:(Detail: String, Success: Bool) -> Void){
        if let nonce = WCNonce{
            let loginInfo = [
                "username" : uname,
                "password" : pwd,
                "woocommerce-login-nonce" : nonce,
                "_wp_http_referer" : "/my-account/",
                "login" : "Login"
            ]
        
            
            Alamofire.request(.POST, BaseURL, parameters: loginInfo)
                .validate().responseString { response in
                    switch response.result {
                        case .Failure(let error):
                            completion(Detail: "Network Problem", Success: false)
                            
                        case .Success(let responseObject):
                            LoginHTMLString = responseObject
                            
                            if let
                                headerFields = response.response?.allHeaderFields as? [String: String],
                                URL = response.request?.URL
                            {
                                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: URL)
                                if cookies.isEmpty{
                                    completion(Detail: "Username or password not correct.", Success: false)
                                } else{
                                    completion(Detail: "Success", Success: true)
                                }
                            }
                            
                        
                    }
            }
        }
    
    }
    
    public func getWCNonce(){
        let url = BaseURL + "/my-account/"
        Alamofire.request(.GET, url).validate()
            .responseString { response in
                switch response.result{
                case .Failure(let error):
                    print(error)
                case .Success(let responseObject):
                    let html = responseObject
                    if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                        for link in doc.xpath(".//*[@id='woocommerce-login-nonce']"){
                            WCNonce = link["value"]
                        }
                    }
                }
        }
    }
    
    public func getWCCustomerInfo(email: String, completion:(Detail: AnyObject, Success: Bool) -> Void){
        let url:NSURL = NSURL(string: "\(BaseURL)/wc-api/v3/customers/email/\(email)?consumer_key=\(WCConsumerKey)&consumer_secret=\(WCSecretKey)")!
        
        Alamofire.request(.GET, url).validate()
            .responseJSON { response in
                switch response.result{
                case .Failure(let error):
                    completion(Detail: "Network Problem", Success: false)
                    
                case .Success(let responseObject):
                    /*print(responseObject)
                    if let phone = responseObject["customer"]!!["billing_address"]!!["phone"]!{
                        print(phone)
                        localStorage.setObject(phone, forKey: localStorageKeys.UserPhone)
                    }
 */
                    completion(Detail: responseObject, Success: true)
                }
        }
    }
}






