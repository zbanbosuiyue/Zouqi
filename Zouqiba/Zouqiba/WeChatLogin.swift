//
//  WeChatLogin.swift
//  Zouqiba
//
//  Created by Miibox on 8/19/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import Foundation

public func WeChatLogin(_ vc: UIViewController){
    if WXApi.isWXAppInstalled(){
        print("wechat login")
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "123"
        WXApi.send(req)
    } else{
        vc.showAlertDoNothing("Error".localized(), message: "Wechat not installed.".localized())
    }

}
