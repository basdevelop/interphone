//
//  AvailableChannel.swift
//  interphone
//
//  Created by wsli on 2017/10/2.
//  Copyright © 2017年 wsli. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class AvailableChannel: NSObject {
        var channelName:String
        var channelId:MCPeerID
        
        init(id: MCPeerID, name:String) {
                self.channelId = id
                self.channelName = name
        }
}
