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
import ImagePicker
import JGProgressHUD

class MainBasicViewController: BasicViewController {
    
    var isOpenedMainMenu = false
    var isOpenedMoreMenu = false
    var isInit = true
    
    var mainMenuView: UIView!
    var moreMenuView: UIView!
    var mainWebView: WKWebView!
    var blurEffectView: UIVisualEffectView!
    var navBar: UINavigationBar!
    var currentWindow: UIWindow!
    let swipeRecognizer = UISwipeGestureRecognizer()
    var hud: JGProgressHUD!
    
    
    lazy var cookieString:String! = {
        let cookiesStorage = HTTPCookieStorage.shared
        var cookieStr = ""
        cookiesStorage.cookies?.forEach({ cookie in
            cookieStr += "\(cookie.name)=\(cookie.value);"
        })
        return cookieStr
    }()

    
    func setNav(){
        navigationController?.navigationBar.isHidden = false
        
        
        let mainMenuItem = UIBarButtonItem(image: UIImage(named: "Menu"), style: .plain, target: self, action: #selector(MainViewController.openMainMenu))
        
        let moreMenuItem = UIBarButtonItem(image: UIImage(named: "moreMenu"), style: .plain, target: self, action: #selector(MainViewController.clickMoreMenu(_:)))
        
        
        let logoImage = UIImage(named: "Logo")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = logoImage
        
        navigationItem.titleView = imageView
        
        navigationItem.leftBarButtonItem = mainMenuItem
        navigationItem.rightBarButtonItem = moreMenuItem
        
        //navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.tintColor = UIColor.black
        
        currentWindow = UIApplication.shared.keyWindow
        
        
        hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = "Loading..."
        hud.textLabel.textColor = UIColor.init(rgb: 0x888888)
        hud.indicatorView = JGProgressHUDPieIndicatorView(hudStyle: hud.style)
    
    }
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
/* ----                  Main MenuView Section                    ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    
    /// Set MainMenu
    func setMainMenuView(){
        mainMenuView = UIView()
        mainMenuView.frame = CGRect(x: -AppWidth * 0.382 , y: StatusHeight + 5,  width: 0, height: 0)
        mainMenuView.backgroundColor = UIColor.white
        mainMenuView.layer.shadowColor = UIColor.gray.cgColor
        mainMenuView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        mainMenuView.layer.shadowOpacity = 0.8
        mainMenuView.layer.shadowRadius = 2.0
        mainMenuView.tag = -1
    }
    
    /// Trigger OpenMainMenu
    func openMainMenu(_ sender: AnyObject){
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
        
        let userImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 80, height: 80))
        if let userPicURL = localStorage.object(forKey: localStorageKeys.UserHeadImageURL){
            userImageView.imageFromServerURL(userPicURL as! String)
        }else{
            if let userHeadImageNSData = localStorage.object(forKey: localStorageKeys.UserHeadImage){
                
                let userHeadImage = UIImage(data: userHeadImageNSData as! Data)
                
                userImageView.image = userHeadImage
            } else{
               userImageView.image = UIImage(named: "DefaultHead")
            }
        }
        
        userImageView.layer.borderWidth = 1
        userImageView.layer.masksToBounds = false
        userImageView.layer.borderColor = UIColor.gray.cgColor
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.clipsToBounds = true
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MainBasicViewController.setUserProfile))
        userImageView.addGestureRecognizer(tap)
        userImageView.isUserInteractionEnabled = true
        
        let mainMenuTableView = TableMenuView(frame:CGRect(x: 0, y: userImageView.frame.height + 10, width: AppWidth * 0.382, height: AppHeight * 0.382))
        mainMenuView.addSubview(mainMenuTableView)
        mainMenuTableView.titles = MainMenuBtnArr
        mainMenuTableView.font = MainMenuBtnFont
        mainMenuTableView.tableView?.rowHeight = 35
        mainMenuTableView.delegate = self
        mainMenuTableView.menuId = 1
        
        currentWindow.addSubview(mainMenuView)
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.mainMenuView.frame = CGRect(x: 0, y: StatusHeight + 5, width: AppWidth * 0.382, height: AppHeight * 0.5)
            
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
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.mainMenuView.frame = CGRect(x: -AppWidth * 0.382 , y: StatusHeight + 5, width: 0, height: 0)
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
        moreMenuView.frame = CGRect(x: AppWidth, y: StatusHeight + 5,  width: 0,  height: 0)
        moreMenuView.backgroundColor = UIColor.white
        
        moreMenuView.layer.shadowColor = UIColor.gray.cgColor
        moreMenuView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        moreMenuView.layer.shadowOpacity = 0.8
        moreMenuView.layer.shadowRadius = 2.0
        moreMenuView.tag = -1
        
    }
    
    /// Trigger OpenMoreMenu
    func clickMoreMenu(_ sender: AnyObject){
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
        
        let moreMenuTableView = TableMenuView(frame: CGRect(x: 0, y: 10, width: AppWidth * 0.3, height: AppHeight * 0.3))
        moreMenuTableView.titles = MoreMenuBtnArr
        moreMenuTableView.font = MoreMenuBtnFont
        moreMenuTableView.tableView?.rowHeight = 30
        moreMenuTableView.delegate = self
        moreMenuTableView.menuId = 2
        
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.moreMenuView.frame = CGRect(x: AppWidth * 0.7, y: StatusHeight + 5, width: AppWidth * 0.3, height: AppHeight * 0.2)
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
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.moreMenuView.frame = CGRect(x: AppWidth, y: StatusHeight + 5,  width: 0,  height: 0)
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
        
        mainWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: AppWidth, height: AppHeight), configuration: setWebConfigByJS(jScript))
        

        mainWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        mainWebView.navigationDelegate = self
        mainWebView.scrollView.delegate = self
        
        //gotoURL(BaseURL)
        self.view.addSubview(mainWebView)

    }


    /// Remove MainWebView
    func removeMainWebView(){
        mainWebView.removeFromSuperview()
    }
    

    
    
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
/* ----              Main Interface Functions               ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    /// Click Outside Menu -- Close Menu
    func tapOutsideMenu(_ sender:AnyObject){
        if isOpenedMainMenu{
            closingMainMenu()
        }
        
        if isOpenedMoreMenu{
            closingMoreMenu()
        }
    }
    
    /// Add BlueEffect
    func addBlurEffect(){
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        blurEffectView.frame = self.view.bounds
        blurEffectView.alpha = 0.2
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.tapOutsideMenu))
        self.blurEffectView.addGestureRecognizer(tap)
        currentWindow.addSubview(blurEffectView)
    }
    
    /// removeBlueEffect
    func removeBlurEffect(){
        blurEffectView.removeFromSuperview()
    }


    
    func setTabBar(){
        
        let tabBarHeight:CGFloat = 50
        
        let tabBar = UITabBar(frame: CGRect(x: -25, y: AppHeight - tabBarHeight, width: AppWidth + 50, height: tabBarHeight))
        
        let backTabBarItem = UITabBarItem(title: "back", image: nil, selectedImage: nil)
        
        let forwardTabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        
        tabBar.setItems([backTabBarItem,forwardTabBarItem], animated: true)
        
        self.view.addSubview(tabBar)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            hud.indicatorView.progress = Float(mainWebView.estimatedProgress)
        }
    }
}


extension MainBasicViewController: UIScrollViewDelegate, TableMenuDelegate, WKNavigationDelegate, ImagePickerDelegate{
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    /* ----        Button And Clicked Funtions       ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    func tableMenuDidChangedToIndex(_ menuId: Int, btnIndex: Int) {
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
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        
        self.navigationController?.pushViewController(LeadingViewController(), animated: true)
    }

    
    func showQRPage(){
        closeAllMenu()
        navigationController?.pushViewController(CameraViewController(), animated: true)
    }
    
    
    func setUserProfile(){
        closeAllMenu()
        
        self.navigationController?.navigationBar.isHidden = true
        let imagePickerVC = CreateUserHeadImageViewController()
        imagePickerVC.delegate = self
        self.navigationController?.pushViewController(imagePickerVC, animated: true)
    }

    ////////////       More Menu Button Functions  ///////////////
    func shareToWeChat(){
        shareWeChat(0)
    }
    
    func shareToMoment(){
        shareWeChat(1)
    }
    
    func shareWeChat(_ scene: Int32){
        let req = SendMessageToWXReq()
        req.text = "KKKKK"
        
        let msg = WXMediaMessage()
        msg.title = "Title"
        msg.setThumbImage(UIImage(named: "Logo"))
        msg.description = "Onepartygo Desc"
        let ext = WXAppExtendObject()
        ext.extInfo = "extInfo"
        ext.url = "http://www.onepartygo.com"
        msg.mediaObject=ext
        req.message = msg
        req.scene = scene
        WXApi.send(req)
    }
    
    func shareToFB(){
        print(CurrentURL)
        let content = FBSDKShareLinkContent()
        content.contentURL = URL(string: BaseURL)
        content.contentTitle = "One Party Go".localized()
        content.contentDescription = "One Party Go: Balalalalaalalla".localized()
        content.imageURL = URL(string: "http://www.onepartygo.com/wp-content/uploads/2016/08/girl-party-1.jpeg")
        FBSDKShareDialog.show(from: self, with: content, delegate: nil)
    }
    
    
    ///////////////////////////////////////////////////////////
    
    
    func gotoURL(_ url:String){
        if url == BaseURL{
            mainWebView.load(URLRequest(url: URL(string: url)!))
            CurrentURL = url
        }
        else if url.contains("http"){
            mainWebView.load(URLRequest(url: URL(string: url)!))
            CurrentURL = url
        } else{
            mainWebView.load(URLRequest(url: URL(string: BaseURL + url)!))
            CurrentURL = BaseURL + url
        }
        
        
        
        closeAllMenu()
    }
    
    func gotoURL(_ url: URLSelector){
        let urlString = url.rawValue
        gotoURL(urlString)
    }
    
    

    
    /////////////////     Delegate Functions    ///////////////////
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //activityIndicator.startAnimating()
        hud.show(in: webView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //activityIndicator.stopAnimating()
        hud.dismiss()
    }
    
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Fire WebView")
    }
    
    
    
    // Set JavaScript for WKWebView
    func setWebConfigByJS(_ jScript: String) -> WKWebViewConfiguration {
        let wkUScript: WKUserScript = WKUserScript(source: jScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController: WKUserContentController = WKUserContentController()
        wkUController.addUserScript(wkUScript)
        
        let wkWebConfig: WKWebViewConfiguration = WKWebViewConfiguration()
        
        wkWebConfig.userContentController = wkUController
        return wkWebConfig
    }
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        print("Wrapper")
        //imagePicker.galleryView.collectionView(images)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        print("done")
        let imagesNSData = UIImagePNGRepresentation(images.last!)
        
        localStorage.set(imagesNSData, forKey: localStorageKeys.UserHeadImage)
        self.navigationController?.popViewController(animated: true)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController){
        print("cancel")
        self.navigationController?.popViewController(animated: true)
    }
}



