//
//  EditVC.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/24.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AVOSCloudIM

class EditVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextView!
    
    //私人信息
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var telTxt: UITextField!
    @IBOutlet weak var genderTxt: UITextField!
    
    var genderPicker : UIPickerView!
    let genders = ["男","女"]    //数据源
    var keyboard = CGRect()
    override func viewDidLoad() {
        super.viewDidLoad()

        //在视图中创建PickerView
        genderPicker = UIPickerView()
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        //检测键盘出现或者消失的状态
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        //单击控制视图后让键盘消失
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        //布局
        let width = self.view.frame.width
        let height = self.view.frame.height
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        avaImg.frame = CGRect(x: width - 78, y: 15, width: 68, height: 68)
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        
        fullnameTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y, width: width - avaImg.frame.width - 30, height: 30)
        usernameTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 40, width: fullnameTxt.frame.width, height: 30)
        webTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: width - 20, height: 30)
        bioTxt.frame = CGRect(x: 10, y: webTxt.frame.origin.y + 40, width: width - 20, height: 60)
        
        //为bioTxt创建一个点的边线
        bioTxt.layer.borderWidth = 1
        bioTxt.layer.borderColor = UIColor(red: 233/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
        
        bioTxt.layer.cornerRadius = bioTxt.frame.width / 50
        bioTxt.clipsToBounds = true
        
        //私人信息的布局
        titleLbl.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 100, width: width - 20, height: 30)
        emailTxt.frame = CGRect(x: 10, y: titleLbl.frame.origin.y + 40, width: width - 20, height: 30)
        telTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 40, width: width - 20, height: 30)
        genderTxt.frame = CGRect(x: 10, y: telTxt.frame.origin.y + 40, width: width - 20, height: 30)
        
        //信息载入
        information()
        
        //设置设置详细信息的头像
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        imgTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(imgTap)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //调出照片获取器选择照片
    func loadImg(recognizer: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    //照片关联到头像处
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    //点击取消按钮
    @IBAction func save_clicked(_ sender: Any) {
        //隐藏虚拟键盘
        self.view.endEditing(true)
        //销毁个人信息编辑控制器
        self.dismiss(animated: true, completion: nil)
    }
    
    //点击确定按钮
    @IBAction func cancel_clicked(_ sender: Any) {
        
        if !validateEmail(email: emailTxt.text!) {
            alert(error: "错误的email地址", message: "请输入正确的email地址")
            return
        }
        if !validateWeb(web: webTxt.text!) {
            alert(error: "错误的web地址", message: "请输入正确的web地址")
            return
        }
        if !validateMobilePhoneNumber(mobilePhoneNumber: telTxt.text!) {
            alert(error: "错误的手机号码", message: "请输入正确的手机号码")
            return
        }
        
        let user = AVUser.current()
        user?.username = usernameTxt.text?.lowercased()
        user?.email = emailTxt.text?.lowercased()
        user?["fullname"] = fullnameTxt.text?.lowercased()
        user?["web"] = webTxt.text?.lowercased()
        user?["bio"] = bioTxt.text
        
        //mobilePhoneNumber是内置属性，而gender不是
        if telTxt.text!.isEmpty {
            user?.mobilePhoneNumber = ""
        } else {
            user?.mobilePhoneNumber = telTxt.text
        }
        
        if genderTxt.text!.isEmpty {
            user?["gender"] = ""
        } else {
            user?["gender"] = genderTxt.text
        }
        
        user?.saveInBackground({ (success: Bool, error: Error?) in
            if success {
                //隐藏键盘
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
            } else {
                print(error?.localizedDescription as Any)
            }
        })
        
    }
    
    //获取器方法
    //组件的数量,用于设置在获取器中显示几列的数据选项
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //获取器选项中的数量
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    //获取器的选项title
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    //从获取器中得到用户选择的Item
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        self.view.endEditing(true)
    }
    
    //隐藏视图中的虚拟键盘
    func hideKeyboardTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //显示视图中的虚拟键盘
    func showKeyboard(notification: Notification) {
        //定义keyboard的大小
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = self.view.frame.height + self.keyboard.height / 2
        }
    }
    
    func hideKeyboard(notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = 0
        }
    }
    
    //获取用户信息
    func information() {
        let ava = AVUser.current()?.object(forKey: "ava") as! AVFile
//        ava.getDataInBackground { (data: Data?, error: Error?) in
//            self.avaImg.image = UIImage(data: data!)
//        }
        usernameTxt.text = AVUser.current()?.username
        fullnameTxt.text = AVUser.current()?.object(forKey: "fullname") as? String
        bioTxt.text = AVUser.current()?.object(forKey: "bio") as? String
        webTxt.text = AVUser.current()?.object(forKey: "web") as? String
        emailTxt.text = AVUser.current()?.email
        telTxt.text = AVUser.current()?.mobilePhoneNumber
        genderTxt.text = AVUser.current()?.object(forKey: "gender") as? String
    }
    
    //正则检查Email有效性
    func validateEmail(email: String) -> Bool {
        let regex = "\\w[-\\w.+]*@([A-Za-z0-9][-A-Za-z0-9]+\\.)+[A-Za-z]{2,14}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    //正则检查Web有效性
    func validateWeb(web: String) -> Bool {
        let regex = "www\\.[A-Za-z0-9._%+-]+\\.[A-Za-z]{2,14}"
        let range = web.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    //正则检查号码的有效性
    func validateMobilePhoneNumber(mobilePhoneNumber: String) -> Bool {
        let regex = "0?(13|14|15|18)[0-9]{9}"
        let range = mobilePhoneNumber.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    //消息警告
    func alert(error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
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
