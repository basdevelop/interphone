//
//  MemeberBeanInChannel.swift
//  interphone
//
//  Created by wsli on 2017/10/3.
//  Copyright © 2017年 wsli. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MemeberBeanInChannel: NSObject {
        var peerID:MCPeerID
        var memberName:String
        var avatar:UIImage?
        var isChannelOwner:Bool = false
        
        init(_ name:String, _ peerID:MCPeerID) {
                self.memberName = name
                self.peerID = peerID
                super.init()
        }
        
        init(_ peerID:MCPeerID) {
                self.memberName = "获取中"
                self.peerID = peerID
                super.init()
        }
}
