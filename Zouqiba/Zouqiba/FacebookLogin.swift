//
//  FacebookLogin.swift
//  Zouqiba
//
//  Created by Miibox on 8/19/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import Foundation

import FBSDKCoreKit
import FBSDKLoginKit




public func facebookLogin(_ vc: UIViewController){
    FBSDKLoginManager().logOut()
    
    let login = FBSDKLoginManager()
    login.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: vc) { (result, error) in
        if error != nil {
            print("kk")
            print(error)
        } else if (result?.isCancelled)! {
        } else {
            let myToken = FBSDKAccessToken.current().tokenString
            
            localStorage.set(myToken, forKey: localStorageKeys.FBAccessToken)
            
            //Show user information
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name, picture.type(large)",])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(error)")
                }else
                {
                    let FBUserInfo = result as! NSDictionary
                    localStorage.set(FBUserInfo, forKey: localStorageKeys.FBUserInfo)
                    print(FBUserInfo)
                    vc.loginProfileCheck()
                }
            })
        }
    }
}


