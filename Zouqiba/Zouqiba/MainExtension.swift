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
    func finishLogin(actionTarget: UIAlertAction){
        print("finish")
        self.navigationController?.pushViewController(MainViewController(), animated: true)
    }
    
    func createProfile(actionTarget: UIAlertAction){
        createProfile()
    }
    
    func createProfileAlert(){
        /// Check email
        if let email = localStorage.objectForKey(localStorageKeys.UserEmail), _ = localStorage.objectForKey(localStorageKeys.UserPhone){
            if let pwd = localStorage.objectForKey(localStorageKeys.UserPwd){
                finishLoginAlert("Success", message: email as! String + " login.")
            } else{
                showAlertDoNothing("Password", message: "Please setup your login password")
                self.navigationController?.pushViewController(CreatePasswordViewController(), animated: true)
            }
            
        } else{
            if let _ = localStorage.objectForKey(localStorageKeys.UserEmail){
                createPhoneAlert()
                //finishLoginAlert("Success", message:  " login.")
            } else {
                createEmailAlert()
            }
        }
    }
 
    func createProfile(){
        /// Check email
        if let email = localStorage.objectForKey(localStorageKeys.UserEmail){
            self.navigationController?.pushViewController(CreatePhoneViewController(), animated: true)
        } else {
            /// Email not exist, go create email
            self.navigationController?.pushViewController(CreateEmailViewController(), animated: true)
        }
    }
    
    
    func loginProfileCheck(){
        if let FBUserInfo = localStorage.objectForKey(localStorageKeys.FBUserInfo){
            print(FBUserInfo)
            if let userHeadImageURL = FBUserInfo["picture"]!!["data"]!!["url"]{
                localStorage.setObject(userHeadImageURL, forKey: localStorageKeys.UserHeadImageURL)
            }
            if let email = FBUserInfo[FBUserInfoSelector.email.rawValue]!{
                localStorage.setObject(email, forKey: localStorageKeys.UserEmail)
            }
        }
        
        if let WeChatUserInfo = localStorage.objectForKey(localStorageKeys.WeChatUserInfo){
            if let userHeadImageURL = WeChatUserInfo[WeChatUserInfoSelector.headImgURL.rawValue]{
                localStorage.setObject(userHeadImageURL, forKey: localStorageKeys.UserHeadImageURL)
            }
        }
        
        
        ///Check if email and phone all setup
        if let email = localStorage.objectForKey(localStorageKeys.UserEmail), phone = localStorage.objectForKey(localStorageKeys.UserPhone), pwd = localStorage.objectForKey(localStorageKeys.UserPwd){
            let email = email as! String
            let phone = phone as! String
            let pwd = pwd as! String
            
            createWCCustomer(email, phone: phone, pwd: pwd,  completion: { (Detail, Success) in
                if Success{
                    self.loginToWC(email, pwd: pwd, completion: { (Detail, Success) in
                        if Success{
                            self.finishLoginAlert("Login", message: email + " is successfully login")
                        }
                    })
                }else{
                    print(Detail)
                }
            })
        } else{
            if let email = localStorage.objectForKey(localStorageKeys.UserEmail) {
                /// Existing User, let them enter pwd to login.
                getWCCustomerInfo(email as! String, completion: { (Detail, Success) in
                    if Success{
                        if let phone = Detail["customer"]!!["billing_address"]!!["phone"]{
                            localStorage.setObject(phone, forKey: localStorageKeys.UserPhone)
                            self.navigationController?.pushViewController(LoginEnterPwdViewController(), animated: true)
                        }
                    }else{
                        print("Error")
                    }
                })
            }
        }
    }
    
    // Alert
    func updateShowError(){
        let alert = UIAlertController(title: "New Version Available", message: "Must Update to Newest Version", preferredStyle: UIAlertControllerStyle.Alert)
        let updateAction = UIAlertAction(title: "Update", style: UIAlertActionStyle.Default, handler: updateHandle)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: cancelHandle)
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Update Handle
    func updateHandle(alter: UIAlertAction!){
        print("Update")
        UIApplication.sharedApplication().openURL(NSURL(string : "https://itunes.apple.com/us/app/miibox/id1033286619?mt=8")!)
    }
    
    func cancelHandle(alert: UIAlertAction!){
        print("Cancel")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        updateShowError()
    }
    
    
    
    func showAlertDoNothing(title: String, message: String){
        let title = title
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func finishLoginAlert(title: String, message: String){
        let title = title
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: self.finishLogin))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func createEmailAlert(){
        let title = "Need Email"
        let message = "Please enter your email address"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: self.createProfile))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func createPhoneAlert(){
        let title = "Need Phone"
        let message = "Please enter your phone number"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: self.createProfile))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    


    func errorViewPage(actionTarget: UIAlertAction){
        print("Error Page")
    }
    
}



extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
                self.contentMode = .ScaleAspectFit
            })
        }).resume()
}}

extension UIView {
    public class func fromNib(nibNameOrNil: String? = nil) -> Self {
        return fromNib(nibNameOrNil, type: self)
    }
    
    
    public class func fromNib<T : UIView>(nibNameOrNil: String? = nil, type: T.Type) -> T {
        let v: T? = fromNib(nibNameOrNil, type: T.self)
        return v!
    }
    
    public class func fromNib<T : UIView>(nibNameOrNil: String? = nil, type: T.Type) -> T? {
        var view: T?
        let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = nibName
        }
        let nibViews = NSBundle.mainBundle().loadNibNamed(name, owner: nil, options: nil)
        for v in nibViews {
            if let tog = v as? T {
                view = tog
            }
        }
        return view
    }
    
    public class var nibName: String {
        let name = "\(self)".componentsSeparatedByString(".").first ?? ""
        return name
    }
    public class var nib: UINib? {
        if let _ = NSBundle.mainBundle().pathForResource(nibName, ofType: "nib") {
            return UINib(nibName: nibName, bundle: nil)
        } else {
            return nil
        }
    }
    

    
}

