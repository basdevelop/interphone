//
//  ChannelMessageBean.swift
//  interphone
//
//  Created by wsli on 2017/10/3.
//  Copyright © 2017年 wsli. All rights reserved.
//

import UIKit

enum MessageType : Int32{
        case MessageTypeVoice
        case MessageTypeVideo
        case MessageTypeTXT
        case MessageTypeImage
}

class ChannelMessageBean: NSObject, NSCoding {
        
        var peerName:String
        var msgType:MessageType
        var data:Data?
        
        init(_ peerName:String, _ msgType:MessageType, _ data:Data?) {
                self.peerName = peerName
                self.msgType = msgType
                self.data = data
                super.init()
        }
        
        public func encode(with aCoder: NSCoder) {
                aCoder.encode(self.peerName, forKey:"peerName")
                aCoder.encodeCInt(self.msgType.rawValue, forKey:"msgType")
                aCoder.encode(self.data, forKey:"data")
        }
        
        required init?(coder aDecoder: NSCoder) {
                self.peerName = aDecoder.decodeObject(forKey: "peerName") as! String
                let mst_type = aDecoder.decodeInt32(forKey: "msgType")
                self.msgType = MessageType(rawValue: mst_type)!
                self.data = aDecoder.decodeObject(forKey: "data") as? Data
        }
        
        static func generateData(_ msg: ChannelMessageBean)->Data{
                return NSKeyedArchiver.archivedData(withRootObject: msg)
        }
        
        static func parseData(_ data:Data)->ChannelMessageBean?{
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? ChannelMessageBean
        }
}
