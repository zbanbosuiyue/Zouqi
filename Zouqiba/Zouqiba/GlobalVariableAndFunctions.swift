//
//  GlobalVariable.swift
//  zouqiTest2
//
//  Created by Miibox on 8/4/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit
import DigitsKit
import FBSDKLoginKit

public let StatusHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
public let NavHeight: CGFloat = 40.0
public let MainViewHeight: CGFloat = NavHeight + StatusHeight + 5
public let AppWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
public let AppHeight: CGFloat = UIScreen.mainScreen().bounds.size.height
public let MainBounds: CGRect = UIScreen.mainScreen().bounds
public let MainMenuBtnFont = UIFont(name: "Arial", size: 14)
public let MoreMenuBtnFont = UIFont(name: "Arial", size: 12)
public var CurrentVersion: Float = 0.9
public let reuseIdentifier = "Cell"
public let MainMenuBtnArr = ["Scan QR", "Home", "Event Calendar", "My Account", "Checkout", "Cart", "Logout"]
public let MoreMenuBtnArr = ["分享到微信", "分享到朋友圈", "分享到Facebook"]

public let localStorage = NSUserDefaults.standardUserDefaults()
public var QRMessage:String! = nil
public var WCErrors:[[String:AnyObject]]! = nil
public var LoginHTMLString: String! = nil
public var Cookies:NSHTTPCookie! = nil
public var WCNonce: String! = nil
public var CurrentURL: String! = nil


public let BaseURL = "https://www.onepartygo.com/"
public let ShareText = "Party Go Share Message"
public let AuthorImage = UIImage(named: "Logo")

public let GeneratePwdLength = 8


public func randomString(length: Int) -> String {
    
    let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let allowedCharsCount = UInt32(allowedChars.characters.count)
    var randomString = ""
    
    for _ in (0..<length) {
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
        randomString += String(newCharacter)
    }
    
    return randomString
}

public func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let result = emailTest.evaluateWithObject(testStr)
    return result
}

public func isValidPhone(value: String) -> Bool {
    let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
    let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
    let result =  phoneTest.evaluateWithObject(value)
    return result
}

public func clearSession(){
    Digits.sharedInstance().logOut()
    FBSDKLoginManager().logOut()
    
    let appDomain = NSBundle.mainBundle().bundleIdentifier
    localStorage.removePersistentDomainForName(appDomain!)
}


struct localStorageKeys {
    static let WeChatAccessToken = "wechat_access_token"
    static let WeChatRefreshToken = "wechat_refresh_token"
    static let WeChatOpenId = "wechat_open_id"
    static let WeChatUserInfo = "wechat_user_info"
    static let FBUserInfo = "fb_user_info"
    
    static let UserFirstName = "user_first_name"
    static let UserEmail = "user_email"
    static let UserHeadImageURL = "user_head_image_url"
    static let UserPhone = "user_phone"
    static let UserPwd = "user_pwd"
}

enum WeChatUserInfoSelector: String{
    case openId = "openid"
    case city = "city"
    case country = "country"
    case name = "nickname"
    case privilege = "privilege"
    case language = "language"
    case headImgURL = "headimgurl"
    case unionId = "unionid"
    case set = "sex"
    case province = "province"
}

enum FBUserInfoSelector: String{
    case firstName = "first_name"
    case id = "id"
    case lastName = "last_name"
    case picture = "picture"
    case email = "email"
}

enum MainButtonNameSelector: Int{
    case scanQRBtn = 0, homeBtn, eventCalendarBtn, myAccountBtn, checkoutBtn, cartBtn, logotBtn, camera
}

enum MoreButtonNameSelector: Int{
    case shareToWeChat = 0, shareToMoment, shareToFB
}

enum URLSelector: String{
    case home = ""
    case eventCalendar = "calendar"
    case myAccount = "my-account"
    case checkout = "checkout"
    case cart = "cart"
}

