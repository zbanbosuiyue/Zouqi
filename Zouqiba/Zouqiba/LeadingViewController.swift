//
//  LeadingViewController.swift
//  zouqiTest2
//
//  Created by Miibox on 8/5/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit
import Localize_Swift
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}




public let Show_ValidatePageViewController_Notification = "Show_ValidatePageViewController_Notification"

class LeadingViewController: BasicViewController{
    var validateView: UIView!
    let backgroundImage = UIImageView(frame: MainBounds)
    var numberTextField: UITextField!
    var actionSheet: UIAlertController!
    var startBtn: UIButton!
    let availableLanguages = Localize.availableLanguages()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        
        backgroundImage.image = UIImage(named: "LeadingPage")
        view.addSubview(backgroundImage)
        
        startBtn = UIButton()
        startBtn.setBackgroundImage(UIImage(named: "into_home"), for: UIControlState())
        startBtn.setTitle("Pick Sign Methods".localized(), for: UIControlState())
        startBtn.setTitleColor(UIColor.red, for: UIControlState())
        startBtn.frame = CGRect(x: (AppWidth - 210) * 0.5, y: AppHeight - 240, width: 210, height: 45)
        //startBtn.addTarget(self, action: #selector(LeadingViewController.showValidatePage), forControlEvents: .TouchUpInside)
        
        let iconPadding:CGFloat = 50.0
        let iconWidth: CGFloat = 50.0
        
        let iconGap: CGFloat = (AppWidth - 2 * iconPadding - 4 * iconWidth) / 3
        
        
        let phoneLoginBtn = UIButton(frame: CGRect(x: iconPadding, y: AppHeight - 160, width: iconWidth, height: iconWidth))
        phoneLoginBtn.setImage(UIImage(named: "Iphone01"), for: UIControlState())
        phoneLoginBtn.contentMode = UIViewContentMode.scaleAspectFit
        phoneLoginBtn.addTarget(self, action: #selector(LeadingViewController.phoneLogin), for: .touchUpInside)
        
        
        let wechatLoginBtn = UIButton(frame: CGRect(x: iconPadding + iconWidth + iconGap,y: AppHeight - 160, width: iconWidth, height: iconWidth))
        wechatLoginBtn.setImage(UIImage(named: "Wechat01"), for: UIControlState())
        wechatLoginBtn.contentMode = UIViewContentMode.scaleAspectFit
        wechatLoginBtn.addTarget(self, action: #selector(LeadingViewController.wechatLogin), for: .touchUpInside)
        
        let fbLoginBtn = UIButton(frame: CGRect(x: iconPadding + iconWidth * 2 + iconGap * 2, y: AppHeight  - 160, width: iconWidth, height: iconWidth))
        fbLoginBtn.setImage(UIImage(named: "Facebook01"), for: UIControlState())
        fbLoginBtn.contentMode = UIViewContentMode.scaleAspectFit
        fbLoginBtn.addTarget(self, action: #selector(LeadingViewController.fbLogin), for: .touchUpInside)

        let moreBtn = UIButton(frame: CGRect(x: iconPadding + iconWidth * 3 + iconGap * 3, y: AppHeight  - 160, width: iconWidth, height: iconWidth))
        moreBtn.setImage(UIImage(named: "SampleIcon"), for: UIControlState())
        moreBtn.contentMode = UIViewContentMode.scaleAspectFit
        moreBtn.addTarget(self, action: #selector(LeadingViewController.sendPostToWC), for: .touchUpInside)
        
        
        view.addSubview(phoneLoginBtn)
        view.addSubview(wechatLoginBtn)
        view.addSubview(fbLoginBtn)
        view.addSubview(moreBtn)
        view.addSubview(startBtn)
        


        NotificationCenter.default.addObserver(self, selector: #selector(setStartBtnText), name: LCLLanguageChangeNotification, object: nil)
        //setVersionCheckor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("abcde")
        navigationController?.navigationBar.isHidden = true
        /// Get WooCoomerce Nonce
        getWCNonce()
        clearSession()
        checkLogin()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    func checkLogin(){
        print("check")
        if let user_email = localStorage.object(forKey: localStorageKeys.UserEmail), let _ = localStorage.object(forKey: localStorageKeys.UserPhone), let _ = localStorage.object(forKey: localStorageKeys.UserPwd)  {
            finishLoginAlert("Welcome", message: user_email as! String + " is successfully login")
        }
    }

    func phoneLogin(){
        //addChildViewController(FabricViewController())
        self.navigationController?.pushViewController(CreatePhoneViewController(), animated: true)
    }
    
    func wechatLogin(){
        WeChatLogin(self)
    }
    

    func fbLogin(){
        facebookLogin(self)
    }
    
    func sendPostToWC(){
        createAppApiUser("a@gmail.com", phone: "123645", pwd: "awefew") { (Detail, Success) in
            
        }
    }
    
    
    func wpApiTest(){
        actionSheet = UIAlertController(title: nil, message: "Switch Language", preferredStyle: UIAlertControllerStyle.actionSheet)
        for language in availableLanguages {
            print(language)
            let displayName = Localize.displayNameForLanguage(language)
            let languageAction = UIAlertAction(title: displayName, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                Localize.setCurrentLanguage(language)
            })
            actionSheet.addAction(languageAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func setStartBtnText(){
        startBtn.setTitle("Pick Sign Methods".localized(), for: UIControlState())
    }
    
    
    func setVersionChecker(){
        let url = "http://www.onepartygo.com/version"
        // Asychronize Request
        Alamofire.request(.GET, url, parameters: ["foo": "bar"])
            .responseJSON { response in
                let isSuccess = response.result.isSuccess
                let html = response.result.value
                if isSuccess{
                    CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingASCII)
                    
                    // If data no structure
                    let serverVersion = Float(String(html!))
                    print(serverVersion)
                    if CurrentVersion < serverVersion{
                        self.updateShowError()
                    }
                    else{
                        // End
                    }
                } else{
                    print("Network Problem")
                    
                }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

