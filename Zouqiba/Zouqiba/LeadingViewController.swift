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



public let Show_ValidatePageViewController_Notification = "Show_ValidatePageViewController_Notification"

class LeadingViewController: BasicViewController{
    var validateView: UIView!
    let backgroundImage = UIImageView(frame: MainBounds)
    var numberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImage.image = UIImage(named: "LeadingPage")
        view.addSubview(backgroundImage)
        
        let startBtn = UIButton()
        startBtn.setBackgroundImage(UIImage(named: "into_home"), forState: .Normal)
        startBtn.setTitle("选择登录方式", forState: UIControlState.Normal)
        startBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        startBtn.frame = CGRect(x: (AppWidth - 210) * 0.5, y: AppHeight - 240, width: 210, height: 45)
        //startBtn.addTarget(self, action: #selector(LeadingViewController.showValidatePage), forControlEvents: .TouchUpInside)
        
        let iconPadding:CGFloat = 50.0
        let iconWidth: CGFloat = 50.0
        
        let iconGap: CGFloat = (AppWidth - 2 * iconPadding - 4 * iconWidth) / 3
        
        
        let phoneLoginBtn = UIButton(frame: CGRectMake(iconPadding, AppHeight - 160, iconWidth, iconWidth))
        phoneLoginBtn.setImage(UIImage(named: "Iphone01"), forState: .Normal)
        phoneLoginBtn.contentMode = UIViewContentMode.ScaleAspectFit
        phoneLoginBtn.addTarget(self, action: #selector(LeadingViewController.phoneLogin), forControlEvents: .TouchUpInside)
        
        
        let wechatLoginBtn = UIButton(frame: CGRectMake(iconPadding + iconWidth + iconGap,AppHeight - 160, iconWidth, iconWidth))
        wechatLoginBtn.setImage(UIImage(named: "Wechat01"), forState: .Normal)
        wechatLoginBtn.contentMode = UIViewContentMode.ScaleAspectFit
        wechatLoginBtn.addTarget(self, action: #selector(LeadingViewController.wechatLogin), forControlEvents: .TouchUpInside)
        
        let fbLoginBtn = UIButton(frame: CGRectMake(iconPadding + iconWidth * 2 + iconGap * 2, AppHeight  - 160, iconWidth, iconWidth))
        fbLoginBtn.setImage(UIImage(named: "Facebook01"), forState: .Normal)
        fbLoginBtn.contentMode = UIViewContentMode.ScaleAspectFit
        fbLoginBtn.addTarget(self, action: #selector(LeadingViewController.fbLogin), forControlEvents: .TouchUpInside)

        let moreBtn = UIButton(frame: CGRectMake(iconPadding + iconWidth * 3 + iconGap * 3, AppHeight  - 160, iconWidth, iconWidth))
        moreBtn.setImage(UIImage(named: "SampleIcon"), forState: .Normal)
        moreBtn.contentMode = UIViewContentMode.ScaleAspectFit
        moreBtn.addTarget(self, action: #selector(LeadingViewController.sendPostToWC), forControlEvents: .TouchUpInside)
        
        
        view.addSubview(phoneLoginBtn)
        view.addSubview(wechatLoginBtn)
        view.addSubview(fbLoginBtn)
        view.addSubview(moreBtn)
        view.addSubview(startBtn)
        
        /// Get WooCoomerce Nonce
        getWCNonce()
        clearSession()
        
        //setVersionCheckor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.hidden = true
    }
    

    func phoneLogin(sender: AnyObject){
        //addChildViewController(FabricViewController())
        self.navigationController?.pushViewController(CreatePhoneViewController(), animated: true)
    }
    
    func wechatLogin(sender: AnyObject){
        WeChatLogin()
    }
    

    func fbLogin(sender: AnyObject){
        facebookLogin(self)
    }
    
    func sendPostToWC(){
        createProfile()
    }
    
    
    
    func setVersionChecker(){
        let url = "http://www.miibox.com/version"
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

