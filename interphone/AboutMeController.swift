//
//  SecondViewController.swift
//  interphone
//
//  Created by wsli on 2017/9/28.
//  Copyright © 2017年 wsli. All rights reserved.
//

import UIKit

class AboutMeController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        @IBOutlet weak var channelPassword: UITextField!
        @IBOutlet weak var channelName: UITextField!
        @IBOutlet weak var userAvatar: UIImageView!
        
        override func viewDidLoad() {
                super.viewDidLoad()
                self.channelName.text = MyInformation.instance.userName
                self.userAvatar.image = MyInformation.instance.avatar
                self.channelPassword.text = MyInformation.instance.channelPassword
                
                self.channelName.delegate = self
                self.channelPassword.delegate = self
        }

        override func didReceiveMemoryWarning() {
                super.didReceiveMemoryWarning()
        }
        
        private func useCamerCaptureImage(alert: UIAlertAction!) {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                        imagePicker.allowsEditing = false
                        self.present(imagePicker, animated: true, completion: nil)
                }else{
                        //TODO::
                }
        }
        
        private func usePhotoLib(alert: UIAlertAction!){
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                        imagePicker.allowsEditing = true
                        self.present(imagePicker, animated: true, completion: nil)
                }else{
                        //TODO::
                }
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
                
                if indexPath.section == 0 && indexPath.row == 0{
                        
                        let alert_action = UIAlertController(title: "提示", message: "请选择图片来源", preferredStyle: .actionSheet)
                        
                        let cancel_action = UIAlertAction(title:"取消", style: .cancel, handler:nil)
                        alert_action.addAction(cancel_action)
                        
                        let camer_action = UIAlertAction(title:"来自照相机", style: .default, handler:useCamerCaptureImage)
                        alert_action.addAction(camer_action)
                        
                        let photo_action = UIAlertAction(title:"来自相册", style: .default, handler:usePhotoLib)
                        alert_action.addAction(photo_action)
                        
                        self.present(alert_action, animated: false, completion: nil)
                }
        }
        
        func shapeUIImageView(_ view: UIImageView){
                let maskPath = UIBezierPath(roundedRect: view.bounds,
                                            byRoundingCorners: [.allCorners],
                                            cornerRadii: CGSize(width: 45.0, height: 45.0))
                
                let shape = CAShapeLayer()
                shape.path = maskPath.cgPath
                view.layer.mask = shape
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
                if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                        self.userAvatar.contentMode = .scaleToFill
                        self.userAvatar.image = pickedImage
                        MyInformation.instance.avatar = pickedImage
                        self.shapeUIImageView(self.userAvatar)
                }
                picker.dismiss(animated: true, completion: nil)
        }
        
        override func viewDidDisappear(_ animated: Bool) {
                super.viewDidDisappear(animated)
                MyInformation.instance.synchrizeData()
        }
}

extension AboutMeController:UITextFieldDelegate{
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                MyInformation.instance.userName = self.channelName.text!
                MyInformation.instance.channelPassword = self.channelPassword.text!
                return false
        }
}

