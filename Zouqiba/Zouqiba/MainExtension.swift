//
//  MainFunctions.swift
//  zouqiTest2
//
//  Created by Miibox on 8/4/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Alamofire
import AVFoundation
import ObjectiveC
import Localize_Swift



// Creates a UIColor from a Hex string.
extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}



extension UIViewController {

    
    func finishLogin(_ actionTarget: UIAlertAction){
        print("finish")
        self.navigationController?.pushViewController(MainViewController(), animated: true)
    }
    
    
    func createProfileAlert(){
        print("aaaa")
        if let email = localStorage.object(forKey: localStorageKeys.UserEmail), let phone = localStorage.object(forKey: localStorageKeys.UserPhone), let pwd = localStorage.object(forKey: localStorageKeys.UserPwd){
            
             /// Check All Profile  ////
            finishLoginAlert("Success", message: email as! String + " login.")
        } else if let email = localStorage.object(forKey: localStorageKeys.UserEmail), let phone = localStorage.object(forKey: localStorageKeys.UserPhone){
            
            /// Email and phone ready, no passsword ////
            createProfileAlert("Setup Password", message: "Please enter your password")
        } else if let email = localStorage.object(forKey: localStorageKeys.UserEmail){
            
            /// Email ready, setup phone ///
            /// Check if email in the database
            let email = email as! String
            getWCCustomerInfo(email, completion: { (Detail, Success) in
                if Success{
                    
                    if let phone = Detail["customer"]!!["billing_address"]!!["phone"]{
                        self.enterPwdAlert("Email Found".localized(), message: email + " has been registered, please login.".localized())
                    } else{
                        self.createProfileAlert("Setup Phone".localized(), message: email + " has been registered, but you need to setup your phone number.".localized())
                    }
                    
                }
                else{
                    self.createProfileAlert("Setup Phone".localized(), message: "Please enter your phone number".localized())
                }
            })
            
        } else{
            /// Setup email ///
            if let name = localStorage.object(forKey: localStorageKeys.UserFirstName){
                print("ddd")
                createProfileAlert("New Customer".localized(), message: name as! String + " please setup your email as login name".localized())
            }else{
                createProfileAlert("New Customer".localized(), message: "Please setup your email as login name".localized())
            }
        }
    }

    
    
    func loginProfileCheck(){
        if let FBUserInfo = localStorage.object(forKey: localStorageKeys.FBUserInfo){
            print(FBUserInfo)
            if let userHeadImageURL = FBUserInfo["picture"]!!["data"]!!["url"]{
                localStorage.set(userHeadImageURL, forKey: localStorageKeys.UserHeadImageURL)
            }
            if let email = FBUserInfo[FBUserInfoSelector.email.rawValue]!{
                localStorage.set(email, forKey: localStorageKeys.UserEmail)
            }
        }
        
        if let WeChatUserInfo = localStorage.object(forKey: localStorageKeys.WeChatUserInfo){
            print("sb")
            if let userHeadImageURL = WeChatUserInfo[WeChatUserInfoSelector.headImgURL.rawValue]{
                localStorage.set(userHeadImageURL, forKey: localStorageKeys.UserHeadImageURL)
            }
            
            if let name = WeChatUserInfo[WeChatUserInfoSelector.name.rawValue]{
                localStorage.set(name, forKey: localStorageKeys.UserFirstName)
            }
        }
        

        ///Check if email and phone all setup
        if let email = localStorage.object(forKey: localStorageKeys.UserEmail), let phone = localStorage.object(forKey: localStorageKeys.UserPhone), let pwd = localStorage.object(forKey: localStorageKeys.UserPwd){
            print("ss")
            let email = email as! String
            let phone = phone as! String
            let pwd = pwd as! String
            
            createAppApiUser(email, phone: phone, pwd: pwd,  completion: { (Detail, Success) in
                if Success{
                    self.createWCCustomer(email, phone: phone, pwd: pwd,  completion: { (Detail, Success) in
                        if Success{
                            print("ksafea")
                            self.loginToWC(email, pwd: pwd, completion: { (Detail, Success) in
                                print("dfsfew")
                                if Success{
                                    self.finishLoginAlert("Login".localized(), message: email + " is successfully login".localized())
                                }
                            })
                        }else{
                            self.showAlertDoNothing("Create WC Customer Error", message: Detail as! String)
                        }
                    })
                }
                else{
                    self.showAlertDoNothing("Create App Api Error", message: Detail as! String)
                }
            })
            

        } else{
            if let email = localStorage.object(forKey: localStorageKeys.UserEmail) {
                /// Existing User, let them enter pwd to login.
                let email = email as! String
                getWCCustomerInfo(email, completion: { (Detail, Success) in
                    if Success{
                        if let phone = Detail["customer"]!!["billing_address"]!!["phone"]{
                            localStorage.set(phone, forKey: localStorageKeys.UserPhone)
                            
                            self.enterPwdAlert("Email Found".localized(), message: email + " has been registered, please login.".localized())
                        }
                    }else{
                        print(Detail)
                    }
                })
            }else{
                /// New Customer
                createProfileAlert()
            }
        }
    }
    
    // Alert
    func updateShowError(){
        let alert = UIAlertController(title: "New Version Available".localized(), message: "Must Update to Newest Version".localized(), preferredStyle: UIAlertControllerStyle.alert)
        let updateAction = UIAlertAction(title: "Update".localized(), style: UIAlertActionStyle.default, handler: updateHandle)
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel, handler: cancelHandle)
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Update Handle
    func updateHandle(_ alter: UIAlertAction!){
        print("Update")
        UIApplication.shared.openURL(URL(string : "https://itunes.apple.com/us/app/miibox/id1033286619?mt=8")!)
    }
    
    func cancelHandle(_ alert: UIAlertAction!){
        print("Cancel")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        updateShowError()
    }
    
    
    
    func showAlertDoNothing(_ title: String, message: String){
        let title = title
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func finishLoginAlert(_ title: String, message: String){
        let title = title
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: self.finishLogin))
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    
    func createProfileAlert(_ title: String, message: String){
        print("cccc")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            switch title{
            case "New Customer".localized():
                print("bbb")
                self.navigationController?.pushViewController(CreateEmailViewController(), animated: true)
            case "Setup Password".localized():
                self.navigationController?.pushViewController(CreatePasswordViewController(), animated: true)
            case "Setup Phone".localized():
                self.navigationController?.pushViewController(CreatePhoneViewController(), animated: true)
            default: break
            }
            
        }))
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }

    func enterPwdAlert(_ title: String, message: String){
        let title = title
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            print("ll")
            self.navigationController?.pushViewController(LoginEnterPwdViewController(), animated: true)
        }))
        
        DispatchQueue.main.async(execute: {
            print("kk")
            self.present(alertController, animated: true, completion: nil)
        })
    }


    func errorViewPage(_ actionTarget: UIAlertAction){
        print("Error Page")
    }
    
}



extension UIImageView {
    public func imageFromServerURL(_ urlString: String) {
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
                self.contentMode = .scaleAspectFit
            })
        }).resume()
}}
