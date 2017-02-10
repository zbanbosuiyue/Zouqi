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
import JGProgressHUD


private let WCConsumerKey = "ck_d9416856e0192556cfb0810cb27df38647adad5b"
private let WCSecretKey = "cs_3e86cad7fd7260dd449ccd1e706e7f64a72bc15d"


extension UIViewController{

    public func createAppApiUser(_ email: String, phone: String, pwd: String, completion:@escaping (_ Detail: AnyObject, _ Success: Bool) -> Void){
        if let wechatUserInfo = localStorage.object(forKey: localStorageKeys.WeChatUserInfo){
            let url = BaseURL + "/wp-api/wp-create-user.php?"
        
            let wechat_access_token = wechatUserInfo["access_token"] as! String
            let wechat_refresh_token = wechatUserInfo["refresh_token"] as! String
            let wechat_open_id = wechatUserInfo["openid"] as! String
            let wechat_union_id = wechatUserInfo["unionid"] as! String
            let user_head_image_url = wechatUserInfo["headimgurl"] as! String
 
            /*
            let wechat_access_token = "dddd"
            let wechat_refresh_token = "cccc"
            let wechat_open_id = "bbbbbb"
            let wechat_union_id = "aaaaaa"
            */
            
            let customerInfo = [
                "wechat_access_token" : wechat_access_token,
                "wechat_refresh_token" : wechat_refresh_token,
                "wechat_openid" : wechat_open_id,
                "wechat_unionid" : wechat_union_id,
                "user_email" : email,
                "user_pwd" : pwd,
                "user_phone" : phone,
                "user_image_url" : user_head_image_url
            ]
        
            Alamofire.request(.GET, url, parameters: customerInfo).responseString { response in
                print(response.request)
                let data = response.result.value!
                print(data)
                if data.contains("Success"){
                    completion(Detail: "", Success: true)
                }else{
                    completion(Detail: data, Success: false)
                }
            }
            
        }else{
            print("Wechat Info Nil")
        }
    
    }
    
    public func createWCCustomer(_ email: String, phone: String, pwd: String, completion:@escaping (_ Detail: AnyObject, _ Success: Bool) -> Void){
        
        let hud = JGProgressHUD(style: .light)
        hud?.textLabel.text = "Creating Customer".localized()
        hud?.show(in: self.view, animated: true)
        
        let customerInfo = [
            "customer" : [
                "email" : email,
                "password" : pwd,
                "billing" : [
                    "phone" : phone
                ]
            ]
        ]
        
        let url:URL = URL(string: "\(BaseURL)/wc-api/v3/customers?consumer_key=\(WCConsumerKey)&consumer_secret=\(WCSecretKey)")!
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: customerInfo, options: [])

        
        Alamofire.request(request)
            .responseJSON { response in
                
                switch response.result {
                case .failure(let error):
                    completion(Detail: "Network Problem", Success: false)
                    hud.textLabel.text = "Network Problem".localized()
                    
                case .success(let responseObject):
                    let responseContent = responseObject as! [String : AnyObject]
                    if let errors = responseContent["errors"] as? [[String : AnyObject]]{
                        completion(Detail: errors, Success: true)
                    } else{
                        completion(Detail: "Created Customer Success", Success: true)
                    }
            }
            
                hud.dismiss(animated: true)
                hud.dismiss(afterDelay: 1.0)
            
        }
        
        
    }
    
    public func loginToWC(_ uname: String, pwd: String, completion:@escaping (_ Detail: String, _ Success: Bool) -> Void){
        let hud = JGProgressHUD(style: .light)
        hud?.textLabel.text = "Try to login"
        hud?.show(in: self.view, animated: true)
        
        
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
                    hud.dismiss()
                    switch response.result {
                        case .failure(let error):
                            completion(Detail: "Network Problem", Success: false)
                            
                        case .success(let responseObject):
                            LoginHTMLString = responseObject
                            if let
                                headerFields = response.response?.allHeaderFields as? [String: String],
                                let URL = response.request?.url
                            {
                                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
                                if cookies.isEmpty{
                                    completion(Detail: "Username or password not correct.", Success: false)
                                } else{
                                    completion(Detail: "Success", Success: true)
                                }
                            }
                            
                        
                    }
            }
        } else {
            self.showAlertDoNothing("Error", message: "Can't get Nonce from website")
        }
    
    }
    
    public func getWCNonce(){
        let url = BaseURL + "/my-account/"
        Alamofire.request(.GET, url).validate()
            .responseString { response in
                switch response.result{
                case .failure(let error):
                    print(error)
                case .success(let responseObject):
                    let html = responseObject
                    if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
                        for link in doc.xpath(".//*[@id='woocommerce-login-nonce']"){
                            WCNonce = link["value"]
                        }
                    }
                }
        }
    }
    
    public func getWCCustomerInfo(_ email: String, completion:@escaping (_ Detail: AnyObject, _ Success: Bool) -> Void){
        let hud = JGProgressHUD(style: .light)
        hud?.textLabel.text = "Finding Customer".localized()
        hud?.show(in: self.view, animated: true)
        
        
        let url:URL = URL(string: "\(BaseURL)/wc-api/v3/customers/email/\(email)?consumer_key=\(WCConsumerKey)&consumer_secret=\(WCSecretKey)")!
        Alamofire.request(.GET, url).validate()
            .responseJSON { response in
                hud.dismiss()
                
                switch response.result{
                case .failure(let error):
                    completion(Detail: error, Success: false)
                    
                case .success(let responseObject):
                    completion(Detail: responseObject, Success: true)
                }
        }
    }
    

}






