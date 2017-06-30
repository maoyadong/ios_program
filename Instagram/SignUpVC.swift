//
//  SignUpVC.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/4.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AVOSCloudIM

class SignUpVC: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passworTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    //根据需要，设置滚动视图的高度
    var scrollViewHeight: CGFloat = 0
    //获取虚拟键盘的大小
    var keyboard: CGRect = CGRect()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //控件布局
        avaImg.frame = CGRect(x: self.view.frame.width / 2 - 40, y: 40, width: 80, height: 80)
        let viewWidth = self.view.frame.width
        usernameTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y + 90, width: viewWidth - 20, height: 30)
        passworTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        repeatPasswordTxt.frame = CGRect(x: 10, y: passworTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        emailTxt.frame = CGRect(x: 10, y: repeatPasswordTxt.frame.origin.y + 60, width: viewWidth - 20, height: 30)
        fullnameTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        bioTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        webTxt.frame = CGRect(x: 10, y: bioTxt.frame.origin.y +  40, width: viewWidth - 20, height: 30)
        signUpBtn.frame = CGRect(x: 20, y: webTxt.frame.origin.y + 50, width: viewWidth / 4, height: 30)
        cancelBtn.frame = CGRect(x: viewWidth - viewWidth / 4 - 20, y: signUpBtn.frame.origin.y, width: viewWidth / 4, height: 30)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = self.view.frame.height
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard),
            name:Notification.Name.UIKeyboardWillHide,object:nil)
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        imgTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.layer.cornerRadius = avaImg.frame.width/2
        avaImg.clipsToBounds = true
        avaImg.addGestureRecognizer(imgTap)
        
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        // Do any additional setup after loading the view.
    }
    
    //头像点击事件
    func loadImg(recognizer: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    func showKeyboard(notification: Notification) {
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.size.height
        }
    }
    func hideKeyboard(notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.view.frame.height
        }
    }

    func hideKeyboardTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //注册按钮点击事件
    @IBAction func signUpBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        if usernameTxt.text!.isEmpty || passworTxt.text!.isEmpty || repeatPasswordTxt.text!.isEmpty || emailTxt.text!.isEmpty || fullnameTxt.text!.isEmpty || bioTxt.text!.isEmpty || webTxt.text!.isEmpty {
            let alert = UIAlertController(title: "请注意", message: "请填写好所有的字段", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //判断两次输入密码是否相同
        if passworTxt.text != repeatPasswordTxt.text {
            let alert = UIAlertController(title: "请注意", message: "两次输入的密码不相同", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel , handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        //发送数据到服务器
        let user = AVUser()
        user.username = usernameTxt.text?.lowercased()     //小写
        user.email = emailTxt.text?.lowercased()
        user.password = passworTxt.text
        user["fullname"] = fullnameTxt.text?.lowercased()
        user["bio"] = bioTxt.text
        user["web"] = webTxt.text?.lowercased()
        user["gender"] = ""
        //转发头像
        let avaData = UIImageJPEGRepresentation(avaImg.image!, 1.0)
        let avaFile = AVFile(name: "ava.jpg", data: avaData!)
        user["ava"] = avaFile
        user.signUpInBackground { (success:Bool, error:Error?) in
            if success {
                print("用户注册成功")
                AVUser.logInWithUsername(inBackground: user.username!, password: user.password!, block: { (
                    user:AVUser?, error:Error?) in
                    if let user = user {
                        //记住登录的用户
                        UserDefaults.standard.set(user.username, forKey: "username")
                        UserDefaults.standard.synchronize()
                    }
                })
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
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
