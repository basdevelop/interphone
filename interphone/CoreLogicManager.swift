//
//  CoreLogicManager.swift
//  interphone
//
//  Created by wsli on 2017/10/2.
//  Copyright © 2017年 wsli. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol ServiceDelegate{
        func serviceFound(service:[ChannelServiceBean])
}
protocol MemberDeleagate {
        func membersChanged(members:[MemeberBeanInChannel])
        func getVoice(_ voiceData:Data?, fromPeer peer:String)
}

class CoreLogicManager: NSObject {
        
        static let instance = CoreLogicManager()
        
        private let MY_SERVICE_TYPE = "inter-phone"
        
        private let myPeerId = MCPeerID(displayName: (UIDevice.current.identifierForVendor?.uuidString)!)
        
        private var serviceAdvertiser: MCNearbyServiceAdvertiser?
        
        private let serviceBrowser : MCNearbyServiceBrowser
        
        private var channelServiceCache :[String : ChannelServiceBean] = [:]
        
        private var membersInCurrentSession : [String : MemeberBeanInChannel] = [:]
        
        var serviceDelegate : ServiceDelegate?
        var memberDelegate : MemberDeleagate?
        
        lazy var currentSession : MCSession = {
                let session = MCSession(peer: self.myPeerId, securityIdentity:nil, encryptionPreference:.required)
                session.delegate = self
                return session
        }()
        
        private override init() {
                self.serviceBrowser = MCNearbyServiceBrowser(peer:self.myPeerId, serviceType:MY_SERVICE_TYPE)
                super.init()
                self.serviceBrowser.delegate = self
                self.serviceBrowser.startBrowsingForPeers()
        }
        
        deinit {
                self.serviceAdvertiser?.stopAdvertisingPeer()
                self.serviceBrowser.stopBrowsingForPeers()
        }
        
        func createAdvertiser(){
                
                if ((self.serviceAdvertiser) != nil){
                        return
                }
                
                let parameter_dic = ["channelName":MyInformation.instance.userName]
                self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer:self.myPeerId,
                                                                   discoveryInfo:parameter_dic,
                                                                   serviceType:MY_SERVICE_TYPE)
                self.serviceAdvertiser?.delegate = self
                self.serviceAdvertiser?.startAdvertisingPeer()
        }
        
        func joinThisChannel(_ peerId:MCPeerID){
                self.serviceBrowser.invitePeer(peerId, to: self.currentSession, withContext: nil, timeout: 0)
        }
}

extension CoreLogicManager : MCNearbyServiceAdvertiserDelegate{
        func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error:Error) {
                NSLog("%@", "-------didNotStartAdvertisingPeer:\(error)-------")
        }
        
        func advertiser(_ advertiser:MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID:MCPeerID, withContext context:Data?, invitationHandler:@escaping (Bool, MCSession?)->Void) {
               
                NSLog("%@", "-------didReceiveInvitationFromPeer \(peerID)-------")
                
                invitationHandler(true, self.currentSession)
        }
        
        func leaveFromChannel(){
                
                self.currentSession.disconnect()
                
                if (self.serviceAdvertiser != nil){
                        self.serviceAdvertiser?.stopAdvertisingPeer()
                        self.serviceAdvertiser = nil
                }
        }
        
        func broadCastTheVoice(_ data : Data){
                do {
                        let connected_peers = self.currentSession.connectedPeers
                        try self.currentSession.send(data, toPeers: connected_peers, with: .unreliable)
                }catch let  error {
                        NSLog("%@", "Error for sending: \(error)")
                }
        }
}


extension CoreLogicManager :MCNearbyServiceBrowserDelegate{
        func browser(_ browser : MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
                NSLog("%@", "-------didNotStartBrowsingForPeers : \(error)-------")
        }
        
        func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID:MCPeerID, withDiscoveryInfo info:[String : String]?)  {
                
                let user_name = info!["channelName"]
                NSLog("%@", "-------foundPeer : \(peerID) user name is :\(user_name ?? "no name")-------")
                
                let new_channel : ChannelServiceBean = ChannelServiceBean(name:user_name!, peerId:peerID)
                
                self.channelServiceCache[peerID.displayName] = new_channel
                
                if ((self.serviceDelegate) != nil){
                        self.serviceDelegate?.serviceFound(service: Array(self.channelServiceCache.values));
                }
        }
        
        func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
                NSLog("%@", "-------lostPeer: \(peerID)-------")
                
                self.channelServiceCache[peerID.displayName] = nil
                
                if ((self.serviceDelegate) != nil){
                        self.serviceDelegate?.serviceFound(service: Array(self.channelServiceCache.values));
                }
        }
}

extension CoreLogicManager : MCSessionDelegate{
        
        func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
                switch state {
                case .notConnected:
                        //TODO:: remove it from list
                        NSLog("-------not  Connected :%@-------", peerID.displayName)
                        self.currentSession.disconnect()
                        self.membersInCurrentSession[peerID.displayName] = nil
                        if ((self.memberDelegate) != nil){
                                self.memberDelegate?.membersChanged(members: Array(self.membersInCurrentSession.values));
                        }
                        break
                case .connected:
                        //TODO:: add it from list
                        NSLog("-------connected :%@-------", peerID.displayName)
                        let new_member : MemeberBeanInChannel = MemeberBeanInChannel(peerID)
                        self.membersInCurrentSession[peerID.displayName] = new_member
                        if ((self.memberDelegate) != nil){
                                self.memberDelegate?.membersChanged(members: Array(self.membersInCurrentSession.values));
                        }
                        break
                case .connecting:
                        NSLog("-------is connnecting :%@-------", peerID.displayName)
                        break
                }
        }
        
        func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
                
                NSLog("%@", "---get data from peer=\(peerID.displayName)---")
                
                let msg:ChannelMessageBean? = ChannelMessageBean.parseData(data)
                
                switch msg?.msgType {
                        
                case .MessageTypeVoice?:
                        if ((self.memberDelegate) != nil){
                                self.memberDelegate?.getVoice(msg?.data, fromPeer: peerID.displayName);
                        }
                        break
                case .none: break
                case .some(.MessageTypeVideo):
                        break
                case .some(.MessageTypeTXT):
                        break
                case .some(.MessageTypeImage):
                        break
                }
        }
        
        func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        }
        
        func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        }
        
        func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        }
}
