//
//  ChannelServiceBean.swift
//  interphone
//
//  Created by wsli on 2017/10/2.
//  Copyright © 2017年 wsli. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ChannelServiceBean: NSObject {
        var channelName:String
        var peerId:MCPeerID
        var avatar:UIImage?
        
        init(name:String, peerId:MCPeerID){
                self.channelName = name
                self.peerId = peerId
                super.init()
        }
}
