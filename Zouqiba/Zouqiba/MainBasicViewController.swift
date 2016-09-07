//
//  MainBasicViewController.swift
//  zouqiTest2
//
//  Created by Miibox on 8/5/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit
import WebKit
import FBSDKShareKit

class MainBasicViewController: BasicViewController {
    
    var isOpenedMainMenu = false
    var isOpenedMoreMenu = false
    var isInit = true
    
    var mainMenuView: UIView!
    var moreMenuView: UIView!
    var mainWebView: WKWebView!
    var activityIndicator: UIActivityIndicatorView!
    var blurEffectView: UIVisualEffectView!
    var navBar: UINavigationBar!
    var currentWindow: UIWindow!
    let swipeRecognizer = UISwipeGestureRecognizer()
    
    
    lazy var cookieString:String! = {
        let cookiesStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        var cookieStr = ""
        cookiesStorage.cookies?.forEach({ cookie in
            cookieStr += "\(cookie.name)=\(cookie.value);"
        })
        return cookieStr
    }()

    
    func setNav(){
        navigationController?.navigationBar.hidden = false
        
        
        let mainMenuItem = UIBarButtonItem(image: UIImage(named: "Menu"), style: .Plain, target: self, action: #selector(MainViewController.openMainMenu(_:)))
        
        let moreMenuItem = UIBarButtonItem(image: UIImage(named: "moreMenu"), style: .Plain, target: self, action: #selector(MainViewController.clickMoreMenu(_:)))
        
        
        let logoImage = UIImage(named: "Logo")
        let imageView = UIImageView(frame: CGRectMake(0, 0, 100, 30))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = logoImage
        
        navigationItem.titleView = imageView
        
        navigationItem.leftBarButtonItem = mainMenuItem
        navigationItem.rightBarButtonItem = moreMenuItem
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        currentWindow = UIApplication.sharedApplication().keyWindow
    }
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
/* ----                  Main MenuView Section                    ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    
    /// Set MainMenu
    func setMainMenuView(){
        mainMenuView = UIView()
        mainMenuView.frame = CGRectMake(-AppWidth * 0.382 , StatusHeight + 5,  0, 0)
        mainMenuView.backgroundColor = UIColor.whiteColor()
        mainMenuView.layer.shadowColor = UIColor.grayColor().CGColor
        mainMenuView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        mainMenuView.layer.shadowOpacity = 0.8
        mainMenuView.layer.shadowRadius = 2.0
        mainMenuView.tag = -1
    }
    
    /// Trigger OpenMainMenu
    func openMainMenu(sender: AnyObject){
        if !isOpenedMainMenu{
            if isOpenedMoreMenu{
                closingMoreMenu()
            }
            openingMainMenu()
            
        } else{
            print("closingMainMenu")
            closingMainMenu()
        }
        
    }
    
    /// Open Main Menu
    func openingMainMenu(){
        addBlurEffect()
        
        let userImageView = UIImageView(frame: CGRectMake(10, 10, 80, 80))
        if let userPicURL = localStorage.objectForKey(localStorageKeys.UserHeadImageURL){
            userImageView.imageFromServerURL(userPicURL as! String)
        }else{
            userImageView.image = UIImage(named: "DefaultHead")
        }
        
        let mainMenuTableView = TableMenuView(frame:CGRectMake(0, userImageView.frame.height + 10, AppWidth * 0.382, AppHeight * 0.382))
        mainMenuView.addSubview(mainMenuTableView)
        mainMenuTableView.titles = MainMenuBtnArr
        mainMenuTableView.font = MainMenuBtnFont
        mainMenuTableView.tableView?.rowHeight = 35
        mainMenuTableView.delegate = self
        mainMenuTableView.menuId = 1
        
        currentWindow.addSubview(mainMenuView)
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.mainMenuView.frame = CGRectMake(0, StatusHeight + 5, AppWidth * 0.382, AppHeight * 0.5)
            
            }, completion: { (Bool) -> Void in
                self.mainMenuView.addSubview(userImageView)
                self.mainMenuView.addSubview(mainMenuTableView)
        })
        
        isOpenedMainMenu = true
    }
    
    /// Close Main Menu
    func closingMainMenu(){
        for v in mainMenuView.subviews {
            v.removeFromSuperview()
        }
        removeBlurEffect()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mainMenuView.frame = CGRectMake(-AppWidth * 0.382 , StatusHeight + 5, 0, 0)
            }, completion: { (Bool) -> Void in
                self.mainMenuView.removeFromSuperview()
        })
        isOpenedMainMenu = false
    }
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    /* ----                More Menu Section          ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    func setMoreMenu(){
        moreMenuView = UIView()
        //moreMenuView.frame = CGRectMake(AppWidth, MainViewHeight, AppWidth * 0.3, AppHeight * 0.2)
        moreMenuView.frame = CGRectMake(AppWidth, StatusHeight + 5,  0,  0)
        moreMenuView.backgroundColor = UIColor.whiteColor()
        
        moreMenuView.layer.shadowColor = UIColor.grayColor().CGColor
        moreMenuView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        moreMenuView.layer.shadowOpacity = 0.8
        moreMenuView.layer.shadowRadius = 2.0
        moreMenuView.tag = -1
        
    }
    
    /// Trigger OpenMoreMenu
    func clickMoreMenu(sender: AnyObject){
        if !isOpenedMoreMenu{
            if isOpenedMainMenu{
                closingMainMenu()
            }
            openingMoreMenu()
        } else{
            closingMoreMenu()
        }
    }
    
    
    /// Opening More Menu
    func openingMoreMenu(){
        addBlurEffect()
        currentWindow.addSubview(moreMenuView)
        
        let moreMenuTableView = TableMenuView(frame: CGRectMake(0, 0, AppWidth * 0.3, AppHeight * 0.3))
        moreMenuTableView.titles = MoreMenuBtnArr
        moreMenuTableView.font = MoreMenuBtnFont
        moreMenuTableView.tableView?.rowHeight = 30
        moreMenuTableView.delegate = self
        moreMenuTableView.menuId = 2
        
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.moreMenuView.frame = CGRectMake(AppWidth * 0.7, StatusHeight + 5, AppWidth * 0.3, AppHeight * 0.2)
            }, completion: { (Bool) -> Void in
                self.moreMenuView.addSubview(moreMenuTableView)
        })
        
        isOpenedMoreMenu = true
    }
    
    
    /// closingMoreMenu
    func closingMoreMenu(){
        for v in moreMenuView.subviews {
            v.removeFromSuperview()
        }
        removeBlurEffect()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.moreMenuView.frame = CGRectMake(AppWidth, StatusHeight + 5,  0,  0)
            }, completion: { (Bool) -> Void in
                self.moreMenuView.removeFromSuperview()
        })
        
        isOpenedMoreMenu = false
        
    }
    
    /// close All Menu
    func closeAllMenu(){
        if isOpenedMainMenu{
            closingMainMenu()
        }
        if isOpenedMoreMenu{
            closingMoreMenu()
        }
    }
    
    

    


    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
/* ----                  Main MainWebView Section                    ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    

    

    
    
    
    /////////////////////////////////////////////////////////
    
    
    /* ----         MainWebView Section     ---- */
    /// Set MainWebView
    func setKKMainWebView(){
        let jScript: String = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=\(AppWidth)'); document.getElementsByTagName('head')[0].appendChild(meta);"
        
        mainWebView = WKWebView(frame: CGRectMake(0, 0, AppWidth, AppHeight), configuration: setWebConfigByJS(jScript))

        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(AppWidth/2 - 10, AppHeight/2 - 10, 10, 10))
        activityIndicator.color = UIColor.blueColor()
        
        mainWebView.navigationDelegate = self
        mainWebView.scrollView.delegate = self
        
        //gotoURL(BaseURL)
        self.view.addSubview(mainWebView)
        self.view.addSubview(activityIndicator)

    }


    /// Remove MainWebView
    func removeMainWebView(){
        mainWebView.removeFromSuperview()
        activityIndicator.removeFromSuperview()
    }
    

    
    
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
/* ----              Main Interface Functions               ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    /// Click Outside Menu -- Close Menu
    func tapOutsideMenu(sender:AnyObject){
        if isOpenedMainMenu{
            closingMainMenu()
        }
        
        if isOpenedMoreMenu{
            closingMoreMenu()
        }
    }
    
    /// Add BlueEffect
    func addBlurEffect(){
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blurEffectView.frame = self.view.bounds
        blurEffectView.alpha = 0.2
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        let tap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.tapOutsideMenu(_:)))
        self.blurEffectView.addGestureRecognizer(tap)
        currentWindow.addSubview(blurEffectView)
    }
    
    /// removeBlueEffect
    func removeBlurEffect(){
        blurEffectView.removeFromSuperview()
    }


    
    func setTabBar(){
        
        let tabBarHeight:CGFloat = 50
        
        let tabBar = UITabBar(frame: CGRectMake(-25, AppHeight - tabBarHeight, AppWidth + 50, tabBarHeight))
        
        let backTabBarItem = UITabBarItem(title: "back", image: nil, selectedImage: nil)
        
        let forwardTabBarItem = UITabBarItem(tabBarSystemItem: .Bookmarks, tag: 1)
        
        tabBar.setItems([backTabBarItem,forwardTabBarItem], animated: true)
        
        self.view.addSubview(tabBar)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension MainBasicViewController: UIScrollViewDelegate, TableMenuDelegate, WKNavigationDelegate{
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    /* ----        Button And Clicked Funtions       ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    func tableMenuDidChangedToIndex(menuId: Int, btnIndex: Int) {
        /// Main Menu
        if menuId == 1{
            let index = MainButtonNameSelector(rawValue: btnIndex)!
            switch index{
            case .scanQRBtn:
                showQRPage()
            case .homeBtn:
                gotoURL(URLSelector.home)
            case .eventCalendarBtn:
                gotoURL(URLSelector.eventCalendar)
            case .myAccountBtn:
                gotoURL(URLSelector.myAccount)
            case .checkoutBtn:
                gotoURL(URLSelector.checkout)
            case .cartBtn:
                gotoURL(URLSelector.cart)
            case .logotBtn:
                logoutApp()
            case .camera:
                showCameraPage()
            }
        }
        
        /// More Menu
        else {
            let index = MoreButtonNameSelector(rawValue: btnIndex)!
            switch index{
            case .shareToWeChat:
                shareToWeChat()
            case .shareToMoment:
                shareToMoment()
            case .shareToFB:
                shareToFB()
            }
        }
        
    }
    
    ////////////////    Main Menu Button Functions /////////////
    
    /// Click Clear Session
    func logoutApp(){
        closingMainMenu()

        
        /// delete cookies
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        
        presentViewController(BaseNavigationController(rootViewController: LeadingViewController()), animated: false, completion: nil)
    }

    
    func showQRPage(){
        navigationController?.pushViewController(CameraViewController(), animated: true)
    }
    
    func showCameraPage(){
        navigationController?.pushViewController(CameraViewController(), animated: true)
    }

    ////////////       More Menu Button Functions  ///////////////
    func shareToWeChat(){
        shareWeChat(0)
    }
    
    func shareToMoment(){
        shareWeChat(1)
    }
    
    func shareWeChat(scene: Int32){
        let req = SendMessageToWXReq()
        req.text = "KKKKK"
        
        let msg = WXMediaMessage()
        msg.title = "Title"
        msg.setThumbImage(UIImage(named: "Logo"))
        msg.description = "Miibox Desc"
        let ext = WXAppExtendObject()
        ext.extInfo = "extInfo"
        ext.url = "http://www.miibox.com"
        msg.mediaObject=ext
        req.message = msg
        req.scene = scene
        WXApi.sendReq(req)
    }
    
    func shareToFB(){
        print(CurrentURL)
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: BaseURL)
        content.contentTitle = "One Party Go"
        content.contentDescription = "One Party Go: Balalalalaalalla"
        content.imageURL = NSURL(string: "http://www.onepartygo.com/wp-content/uploads/2016/08/girl-party-1.jpeg")
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
    }
    
    
    ///////////////////////////////////////////////////////////
    
    
    func gotoURL(url:String){
        if url == BaseURL{
            mainWebView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
            CurrentURL = url
        }
        else if url.containsString("http"){
            mainWebView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
            CurrentURL = url
        } else{
            mainWebView.loadRequest(NSURLRequest(URL: NSURL(string: BaseURL + url)!))
            CurrentURL = BaseURL + url
        }
        
        
        
        closeAllMenu()
    }
    
    func gotoURL(url: URLSelector){
        let urlString = url.rawValue
        gotoURL(urlString)
    }
    
    

    
    /////////////////     Delegate Functions    ///////////////////
    
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        print("Fire WebView")
    }
    
    
    // Set JavaScript for WKWebView
    func setWebConfigByJS(jScript: String) -> WKWebViewConfiguration {
        let wkUScript: WKUserScript = WKUserScript(source: jScript, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
        let wkUController: WKUserContentController = WKUserContentController()
        wkUController.addUserScript(wkUScript)
        
        let wkWebConfig: WKWebViewConfiguration = WKWebViewConfiguration()
        
        wkWebConfig.userContentController = wkUController
        return wkWebConfig
    }
}
