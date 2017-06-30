//
//  NavVC.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/26.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit

class NavVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //导航栏中Title的颜色设置
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        //导航栏中的按钮的颜色
        self.navigationBar.tintColor = .white
        //导航栏的背景色
        self.navigationBar.barTintColor = UIColor(red: 18.0 / 255.0, green: 86.0 / 255.0, blue: 136.0 / 255.0, alpha: 1)
        
        //不允许透明
        self.navigationBar.isTranslucent = false
        // Do any additional setup after loading the view.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
