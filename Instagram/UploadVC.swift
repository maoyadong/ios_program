//
//  UploadVC.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/25.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AVOSCloudIM

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeBtn.isHidden = true
        //默认状态下禁用publishBtn按钮
        publishBtn.isEnabled = false
        publishBtn.backgroundColor = .lightGray
        
        //单击Image View
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(selectImg))
        imgTap.numberOfTapsRequired = 1
        self.picImg.isUserInteractionEnabled = true
        self.picImg.addGestureRecognizer(imgTap)
        // Do any additional setup after loading the view.
        
        picImg.image = UIImage(named: "bg.jpg")
        titleTxt.text = ""
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alignment()
    }
    func alignment() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        picImg.frame = CGRect(x: 15, y: 15, width: width / 4.5, height: width / 4.5)
        
        titleTxt.frame = CGRect(x: picImg.frame.width + 25, y: picImg.frame.origin.y, width: width - titleTxt.frame.origin.x - 10, height: picImg.frame.height)
        
        publishBtn.frame = CGRect(x: 0, y: height - width / 8, width: width, height: width / 8)
        
        removeBtn.frame = CGRect(x: picImg.frame.origin.x, y: picImg.frame.origin.y + picImg.frame.height + 10, width: picImg.frame.width, height: 30)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectImg() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    //将照片放入picImg，并销毁照片获取器
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //获取处理后用户编辑后的照片
        picImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        //显示 移除按钮
        removeBtn.isHidden = false
        
        //允许使用按钮
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0 / 255.0, green: 169.0 / 255.0, blue: 255.0, alpha: 1)
        
        //实现第二次点击放大图片
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomImg))
        zoomTap.numberOfTapsRequired = 1
        self.picImg.isUserInteractionEnabled = true
        self.picImg.addGestureRecognizer(zoomTap)
    }
    
    //放大或者缩小图片
    func zoomImg() {
        //放大后的Image View的位置
        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x - navigationController!.navigationBar.frame.height * 1.5, width: self.view.frame.width, height: self.view.frame.width)
        //还原到初始位置
        let unzoomed = CGRect(x: 15, y: 15, width: self.view.frame.width / 4.5, height: self.view.frame.width / 4.5)
        
        if picImg.frame == unzoomed {
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = zoomed
                self.view.backgroundColor = .black
                
                self.titleTxt.alpha = 0
                self.publishBtn.alpha = 0
                self.removeBtn.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = unzoomed
                self.view.backgroundColor = .white
                self.titleTxt.alpha = 1
                self.publishBtn.alpha = 1
                self.removeBtn.alpha = 0
            })
        }
        
    }
    
    @IBAction func removeBtn_clicked(_ sender: AnyObject) {
        self.viewDidLoad()
    }
    
    @IBAction func publishBtn_clicked(_ sender: AnyObject) {
        self.view.endEditing(true)
        let object = AVObject(className: "Posts")
        object["username"] = AVUser.current()?.username
        object["ava"] = AVUser.current()?.value(forKey: "ava") as! AVFile
        object["puuid"] = "\(String(describing: AVUser.current()?.username!)) \(NSUUID().uuidString)"
        //title是否为空
        if titleTxt.text.isEmpty {
            object["title"] = ""
        } else {
            //去除空格和换行符
            object["title"] = titleTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        //生成照片数据
        let imageData = UIImageJPEGRepresentation(picImg.image!, 1)
        let imageFile = AVFile(name: "post.jpg", data: imageData!)
        object["pic"] = imageFile
        
        //将数据存储到LeanCloud云端
        object.saveInBackground({ (success: Bool?, error: Error?) in
            if error == nil {
                //发送uploaded通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil, userInfo: nil)
                //将TabBar控制器中索引值调为0
                self.tabBarController?.selectedIndex = 0
            }
        })
        
        self.viewDidLoad()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
