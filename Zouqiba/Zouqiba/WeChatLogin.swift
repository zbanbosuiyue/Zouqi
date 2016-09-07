//
//  WeChatLogin.swift
//  Zouqiba
//
//  Created by Miibox on 8/19/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import Foundation

public func WeChatLogin(){
    print("wechat login")
    let req = SendAuthReq()
    req.scope = "snsapi_userinfo"
    req.state = "123"
    WXApi.sendReq(req)
}