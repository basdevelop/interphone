//
//  MyInformation.swift
//  interphone
//
//  Created by wsli on 2017/10/2.
//  Copyright © 2017年 wsli. All rights reserved.
//

import UIKit

final class MyInformation: NSObject, NSCoding {
        
        var userName:String
        var avatar:UIImage?
        var channelPassword:String?
        
        public static let DATA_KEY_FOR_SAVE:String = "personData"
        
        static let instance = MyInformation()
        
        private override init() {
                if let loadedData = UserDefaults().data(forKey: MyInformation.DATA_KEY_FOR_SAVE) {
                      let my_info = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? MyInformation
                        self.userName = (my_info?.userName)!
                        self.avatar = my_info?.avatar
                        if my_info?.channelPassword != nil{
                                self.channelPassword = (my_info?.channelPassword)!
                        }
                }else{
                        self.userName = UIDevice.current.name
                        self.channelPassword = nil;
                        self.avatar = nil;
                }
                
                if self.avatar == nil {
                        self.avatar = UIImage.init(named: "mine_head_acquiesce_img")
                }
                
                super.init()
        }
        
        
        func encode(with aCoder: NSCoder) {
                aCoder.encode(self.userName, forKey:"userName")
                aCoder.encode(self.channelPassword, forKey:"channelPassword")
                aCoder.encode(self.avatar, forKey:"avatar")
        }
        
        init?(coder aDecoder: NSCoder) {
                self.userName = aDecoder.decodeObject(forKey:"userName") as! String
                self.channelPassword = aDecoder.decodeObject(forKey:"channelPassword") as? String
                self.avatar = (aDecoder.decodeObject(forKey:"avatar") as! UIImage)
        }
        
        func synchrizeData(){
                let data = NSKeyedArchiver.archivedData(withRootObject: self)
                UserDefaults().set(data, forKey: MyInformation.DATA_KEY_FOR_SAVE)
                UserDefaults().synchronize()
        }
}
