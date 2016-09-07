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

public func facebookLogin(vc: UIViewController){
    FBSDKLoginManager().logOut()
    
    let login = FBSDKLoginManager()
    login.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: vc) { (result, error) in
        if error != nil {
            print("kk")
            print(error)
        } else if result.isCancelled {
            print("Cancelled")
        } else {
            //Show user information
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name, picture.type(large)",])
            
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(error)")
                }else
                {
                    let FBUserInfo = result as! NSDictionary
                    localStorage.setObject(FBUserInfo, forKey: localStorageKeys.FBUserInfo)
                    vc.loginProfileCheck()
                }
            })
        }
    }
}