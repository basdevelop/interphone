//
//  ChannelViewController.swift
//  interphone
//
//  Created by wsli on 2017/10/2.
//  Copyright © 2017年 wsli. All rights reserved.
//

import UIKit
import AVFoundation

class ChannelViewController: UIViewController {
        
        @IBOutlet weak var voiceRecordBtn: UIButton!
        let coreLogicManager = CoreLogicManager.instance
        
        var serviceBean:ChannelServiceBean?
        
        var audioPlayer: AVAudioPlayer?
        var audioRecorder: AVAudioRecorder?
        
        override func viewDidLoad() {
                super.viewDidLoad()
                if (self.serviceBean != nil){
                        coreLogicManager.joinThisChannel((self.serviceBean?.peerId)!)
                }
                coreLogicManager.memberDelegate = self
                voiceRecordBtn.setImage(UIImage(named:"voice_record"), for: .normal)
                voiceRecordBtn.setImage(UIImage(named:"voice_record_down"), for: .highlighted)
                
                let dir_paths = FileManager.default.urls(for: .documentDirectory,
                                                         in: .userDomainMask)
                
                let saved_url = dir_paths[0].appendingPathComponent("this_is_tmp_record_file.caf")
                
                let audio_session = AVAudioSession.sharedInstance()
                do{ try  audio_session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                     try audio_session.overrideOutputAudioPort(.speaker)
                }catch let error as NSError{
                        NSLog("%@", "audioSession error: \(error.localizedDescription)")
                }
                
                let record_settings =
                        [AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
                         AVEncoderBitRateKey: 16,
                         AVNumberOfChannelsKey: 2,
                         AVSampleRateKey: 44100.0] as [String : Any]
                
                do {
                        try audioRecorder = AVAudioRecorder(url: saved_url,
                                                            settings: record_settings as [String : AnyObject])
                        audioRecorder?.delegate = self
                        audioRecorder?.prepareToRecord()
                        NSLog("%@", "prepared to record voice : \(audioRecorder?.url.absoluteString ?? "----")")
                        
                } catch let error as NSError {
                         NSLog("%@", "audioSession error: \(error.localizedDescription)")
                }
        }
        
        override func viewDidDisappear(_ animated: Bool) {
                super.viewDidDisappear(animated)
                coreLogicManager.leaveFromChannel()
        }

        override func didReceiveMemoryWarning() {
                super.didReceiveMemoryWarning()
        }
        
        func renderByServiceInfo(_ serviceBean:ChannelServiceBean){
                self.title = serviceBean.channelName
                self.serviceBean = serviceBean;
        }
        
        func renderByMyInfo() -> Void {
                self.title = MyInformation.instance.userName
        }
        
        @IBAction func startToRecord(_ sender: UIButton) {
                if audioRecorder?.isRecording == false {
                        audioRecorder?.record()
                }
        }
        
        @IBAction func finishedRecord(_ sender: UIButton) {
                if audioRecorder?.isRecording == true{
                        audioRecorder?.stop()
                        let abs_path = audioRecorder?.url.path
                        let voice_data = FileManager.default.contents(atPath: abs_path!)
                        let msg:ChannelMessageBean = ChannelMessageBean("all", .MessageTypeVoice, voice_data)
                        
                        coreLogicManager.broadCastTheVoice(ChannelMessageBean.generateData(msg))
                }
        }
}

extension ChannelViewController : MemberDeleagate{
        func membersChanged(members:[MemeberBeanInChannel]){
        }
        
        func getVoice(_ voiceData:Data?, fromPeer peer:String){
                do {
                        try audioPlayer = AVAudioPlayer(data:voiceData!)
                        audioPlayer!.delegate = self
                        audioPlayer!.prepareToPlay()
                        audioPlayer!.play()
                } catch let error as NSError {
                        print("audioPlayer error: \(error.localizedDescription)")
                }
        }
}

extension ChannelViewController : AVAudioPlayerDelegate, AVAudioRecorderDelegate{
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
                 print("Audio Play did finish playing.")
        }
        
        func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
                print("Audio Play Decode Error")
        }
        
        func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
                 print("Audio record did finish recording.")
        }
        
        func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
                print("Audio Record Encode Error")
        }
}
