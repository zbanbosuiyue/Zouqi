//
//  AppDelegate.swift
//  Zouqiba
//
//  Created by Miibox on 8/12/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit
import Fabric
import DigitsKit
import Crashlytics
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import JGProgressHUD


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {
    
    fileprivate var WeChatAccessToken:String!
    fileprivate var WeChatRefreshToken:String!
    fileprivate var WeChatResponseCode:String!
    fileprivate var WeChatOpenId:String!
    fileprivate var WeChatUnionId:String!
    
    let facebookReadPermissions = ["public_profile", "email", "user_friends"]
    var window: UIWindow?
    var navController: BaseNavigationController?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        navController = BaseNavigationController(rootViewController: LeadingViewController())
        Fabric.with([Digits.self, Crashlytics.self])
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        setKeyWindow()
        setWeChat()
        

        return true
    }
    
    func setKeyWindow(){
        window = UIWindow(frame: MainBounds)
        window?.rootViewController = showLeadPage()
        window?.makeKeyAndVisible()
    }
    
    
    func showLeadPage()-> UIViewController{        
        if let _ = localStorage.object(forKey: localStorageKeys.UserEmail), let _ = localStorage.object(forKey: localStorageKeys.UserPhone), let _ = localStorage.object(forKey: localStorageKeys.UserPwd)  {
            return BaseNavigationController(rootViewController: MainViewController())
        }
        
        return navController!
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) || WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func setWeChat(){
        print("a")
        WXApi.registerApp("wx9a39f6535f6df026")
    }
    
    func onReq(_ req: BaseReq!) {
        print("b")
        print(req.type)
    }
    
    func onResp(_ resp: BaseResp!) {
        print("c")
        if resp.isKind(of: SendAuthResp.self) {
            let response = resp as! SendAuthResp
            if response.code != nil{
                print("OK")
                self.WeChatResponseCode = response.code
                print(response.code)
                
                getWeChatUserInfo(response.code)

            } else {
                print("Fail to Login")
            }
//            print("finished")
        }
    }
    
    
    func getWeChatUserInfo(_ response_code: String){
        print("abc")
        let url = BaseURL + "wp-api/wp-api.php?"
        
        let hud = JGProgressHUD(style: .light)
        hud?.textLabel.text = "Retriving info from Wechat".localized()
        hud?.show(in: window?.rootViewController?.view, animated: true)
        
        Alamofire.request(.GET, url, parameters: ["wechat_response_code" : response_code]).responseJSON { response in
            hud.dismiss()
            print(response.request)
            switch response.result{
            case .failure:
                hud.textLabel.text = "Network Problem".localized();
            case .success:
                let data = response.result.value!
                if let userExist = data["user_exist"]{
                    let userExist = userExist as! Bool
                    if userExist{
                        print(data)
                        /// Get userEmail and pwd to login.
                        let user_email = data["user_email"] as! String
                        let user_phone = data["user_phone"] as! String
                        let user_pwd = data["user_pwd"] as! String
                        
                        let wechat_access_token = data["wechat_access_token"]
                        let wechat_refresh_token = data["wechat_refresh_token"]
                        let wechat_openid = data["wechat_openid"]
                        let user_image_url = data["user_image_url"]
                        
                        
                        localStorage.set(user_email, forKey: localStorageKeys.UserEmail)
                        localStorage.set(user_phone, forKey: localStorageKeys.UserPhone)
                        localStorage.set(user_pwd, forKey: localStorageKeys.UserPwd)
                        localStorage.set(user_image_url, forKey: localStorageKeys.UserHeadImageURL)

                        localStorage.set(wechat_access_token, forKey: localStorageKeys.WeChatAccessToken)
                        localStorage.set(wechat_refresh_token, forKey: localStorageKeys.WeChatRefreshToken)
                        localStorage.set(wechat_openid, forKey: localStorageKeys.WeChatOpenId)
                        
                        
                        
                        self.navController?.viewControllers.last!.loginToWC(user_email, pwd: user_pwd, completion: { (Detail, Success) in
                            if Success{
                                print(data)
                                self.window?.rootViewController?.show(MainViewController(), sender: self)
                                
                                print("sksk")
                            } else{
                                print("failed")
                            }
                        })
                        

                        
                    } else{
                        print(data)
                        let wechatUserInfo = data
                        localStorage.set(wechatUserInfo, forKey: localStorageKeys.WeChatUserInfo)
                        DispatchQueue.main.async{
                            self.navController?.viewControllers.last!.loginProfileCheck()
                        }
                    }
                }
            }
            
            
        }
    }
    
   /*
    /// Return to WeChatAccessToken and WeChatRefreshToken
    func getWeChatAccessAndRefreshToken(response_code: String){
        print("e")
        
        let url = "https://www.miibox.com/wp2/wp-api/wp-api.php?"
        let url2 = "http://192.168.1.119/wp-api/wp-api.php?"
        
        Alamofire.request(.GET, url2, parameters: ["wechat_response_code" : response_code]).responseJSON { response in
            print(response.result.value)
            localStorage.setValue(self.WeChatAccessToken, forKey: "WeChatAccessToken")
            localStorage.setValue(self.WeChatRefreshToken, forKey: "WeChatRefreshToken")
            localStorage.setValue(self.WeChatOpenId, forKey: "WeChatOpenId")
            
            if self.WeChatAccessToken != nil{
                self.getWeChatUserInfo()
            }
        }
        
     
        Alamofire.request(.GET, "https://api.weixin.qq.com/sns/oauth2/access_token?", parameters: ["appid" : "wx9a39f6535f6df026", "secret": "4f1947ebe40b41ebd7fc233d1ba6a5b3", "code": response_code ,"grant_type": "authorization_code"]).responseJSON { response in
            let data = response.result.value as! NSDictionary
            self.WeChatAccessToken = data["access_token"]! as! String
            self.WeChatRefreshToken = data["refresh_token"]! as! String
            self.WeChatOpenId = data["openid"]! as! String
            
            print(data)
            localStorage.setValue(self.WeChatAccessToken, forKey: "WeChatAccessToken")
            localStorage.setValue(self.WeChatRefreshToken, forKey: "WeChatRefreshToken")
            localStorage.setValue(self.WeChatOpenId, forKey: "WeChatOpenId")
        
            if self.WeChatAccessToken != nil{
                self.getWeChatUserInfo()
            }
        }
 
    }
    */
    func setNotification(){
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.showMainViewController), name: Show_ValidatePageViewController_Notification, object: nil)
    }
    

}
