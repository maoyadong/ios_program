//
//  ResetPasswordVC.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/4.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AVOSCloudIM
class ResetPasswordVC: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxt.frame = CGRect(x: 10, y: 120, width: self.view.frame.width, height: 30)
        resetBtn.frame = CGRect(x: 20, y: emailTxt.frame.origin.y + 50, width: self.view.frame.width / 4, height: 30)
        cancelBtn.frame = CGRect(x: self.view.frame.width / 4 * 3 - 20, y: resetBtn.frame.origin.y, width: self.view.frame.width / 4, height: 30)
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        // Do any additional setup after loading the view.
    }

    @IBAction func resetBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        if emailTxt.text!.isEmpty {
            let alert = UIAlertController(title: "请注意", message: "电子邮件不能为空", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        AVUser.requestPasswordResetForEmail(inBackground: emailTxt.text!) { (success:Bool,error:Error?) in
            if success {
                let alert = UIAlertController(title: "请注意", message: "重置密码连接已经发送到您的电子邮件", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: {
                    (_) in self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    
    }
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    func hideKeyBoard(recongnizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
