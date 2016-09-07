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
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {
    
    private var WeChatAccessToken:String!
    private var WeChatRefreshToken:String!
    private var WeChatResponseCode:String!
    private var WeChatOpenId:String!
    private var WeChatUnionId:String!
    
    
    var window: UIWindow?
    var navController: BaseNavigationController?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
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
        if let _ = localStorage.objectForKey(localStorageKeys.UserEmail), _ = localStorage.objectForKey(localStorageKeys.UserPhone)  {
            return BaseNavigationController(rootViewController: MainViewController())
        }
        
        return navController!
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) || WXApi.handleOpenURL(url, delegate: self)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func setWeChat(){
        WXApi.registerApp("wx9a39f6535f6df026")
    }
    
    func onReq(req: BaseReq!) {
        print(req.type)
    }
    
    func onResp(resp: BaseResp!) {
        if resp.isKindOfClass(SendAuthResp) {
            let response = resp as! SendAuthResp
            if response.code != nil{
                print("OK")
                self.WeChatResponseCode = response.code
                getWeChatAccessAndRefreshToken(response.code)

            } else {
                print("Fail to Login")
            }
//            print("finished")
        }
    }
    
    
    func getWeChatUserInfo(){
        Alamofire.request(.GET, "https://api.weixin.qq.com/sns/userinfo?", parameters: ["access_token": WeChatAccessToken, "openid": WeChatOpenId]).responseJSON { response in
            let WeChatUserInfo = response.result.value as! [String: AnyObject]
            
            localStorage.setValue(WeChatUserInfo, forKey: "WeChatUserInfo")
            
            dispatch_async(dispatch_get_main_queue()){
                self.navController?.viewControllers.last!.loginProfileCheck()
            }
        }

    }
    
    
    /// Return to WeChatAccessToken and WeChatRefreshToken
    func getWeChatAccessAndRefreshToken(response_code: String){
        Alamofire.request(.GET, "https://api.weixin.qq.com/sns/oauth2/access_token?", parameters: ["appid" : "wx9a39f6535f6df026", "secret": "4f1947ebe40b41ebd7fc233d1ba6a5b3", "code": response_code ,"grant_type": "authorization_code"]).responseJSON { response in
            let data = response.result.value as! NSDictionary
            self.WeChatAccessToken = data["access_token"]! as! String
            self.WeChatRefreshToken = data["refresh_token"]! as! String
            self.WeChatOpenId = data["openid"]! as! String
            
            
            localStorage.setValue(self.WeChatAccessToken, forKey: "WeChatAccessToken")
            localStorage.setValue(self.WeChatRefreshToken, forKey: "WeChatRefreshToken")
            localStorage.setValue(self.WeChatOpenId, forKey: "WeChatOpenId")
        
            if self.WeChatAccessToken != nil{
                self.getWeChatUserInfo()
            }
            
        }
    }
    
    func setNotification(){
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.showMainViewController), name: Show_ValidatePageViewController_Notification, object: nil)
    }

}