//
//  FirstViewController.swift
//  interphone
//
//  Created by wsli on 2017/9/28.
//  Copyright © 2017年 wsli. All rights reserved.
//

import UIKit

class InterPhoneController: UITableViewController { 

        let coreLogicManager = CoreLogicManager.instance
        
        var foundedServices :[ChannelServiceBean] = []
        
        @objc func createNewChannel(){
                let channel_vc:ChannelViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChannelViewController") as! ChannelViewController
                channel_vc.renderByMyInfo()
                self.navigationController?.pushViewController(channel_vc, animated: true)
                self.coreLogicManager.createAdvertiser()
        }
        
        override func viewDidLoad() { 
                super.viewDidLoad()
                
                let create_channel:UIBarButtonItem = UIBarButtonItem(title:"创建频道", style:.done, target:self, action:#selector(InterPhoneController.createNewChannel))
                
                self.navigationItem.rightBarButtonItem = create_channel;
                
                self.coreLogicManager.serviceDelegate = self
        }

        override func didReceiveMemoryWarning() {
                super.didReceiveMemoryWarning() 
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int {
                return 1;
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return self.foundedServices.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CHANNEL_ITEM_CELL", for: indexPath)
                let one_record : ChannelServiceBean = self.foundedServices[indexPath.row]
                cell.textLabel?.text = one_record.channelName
                return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                let one_record : ChannelServiceBean = self.foundedServices[indexPath.row]
                
                let channel_vc : ChannelViewController =  self.storyboard?.instantiateViewController(withIdentifier: "ChannelViewController") as! ChannelViewController
                channel_vc.renderByServiceInfo(one_record)
                self.navigationController?.pushViewController(channel_vc, animated: true)
        }
}

extension InterPhoneController :ServiceDelegate{
        func serviceFound(service:[ChannelServiceBean]){
                self.foundedServices = service
                self.tableView.reloadData()
        }
}

