//
//  HeaderView.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/9.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AVOSCloudIM
class HeaderView: UICollectionReusableView {
    
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var webTxt: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var follwers: UILabel!
    @IBOutlet weak var followings: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var follwersTitle: UILabel!
    @IBOutlet weak var followingsTitle: UILabel!
    @IBOutlet weak var button: UIButton!
    
    
    @IBAction func followBtn_clicked(_ sender: Any) {
        
        let title = button.title(for: .normal)
        let user = guestArray.last
        if title == "关 注" {
            
            guard let user = user else { return }
            AVUser.current()?.follow(user.objectId!, andCallback: { (success:Bool, error: Error?) in
                if success {
                    self.button.setTitle("√ 已关注", for: .normal)
                    self.button.backgroundColor = .green
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
            
        } else {
            guard let user = user else {
                return
            }
            AVUser.current()?.unfollow(user.objectId!, andCallback: { (success:Bool,error: Error?) in
                if success {
                    self.button.setTitle("关 注", for: .normal)
                    self.button.backgroundColor = .lightGray
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
        }

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //对齐
        let width = UIScreen.main.bounds.width
        
        //对头像进行布局
        avaImg.frame = CGRect(x: width / 16, y: width/16, width: width / 4 , height: width / 4)
        
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        
        //对三个统计数据进行布局
        posts.frame = CGRect(x: width / 2.5, y: avaImg.frame.origin.y, width: 50, height: 30)
        follwers.frame = CGRect(x: width / 1.6, y: avaImg.frame.origin.y, width: 50, height: 30)
        followings.frame = CGRect(x: width / 1.2, y: avaImg.frame.origin.y, width: 50, height: 30)
        
        //设置三个的布局
        postTitle.center = CGPoint(x: posts.center.x, y: posts.center.y + 20)
        follwersTitle.center = CGPoint(x: follwers.center.x, y: follwers.center.y + 20)
        followingsTitle.center = CGPoint(x: followings.center.x, y: followings.center.y + 20)
        
        //设置按钮的布局
        button.frame = CGRect(x: postTitle.frame.origin.x, y: postTitle.frame.origin.y + 25, width: width - postTitle.frame.origin.x - 10, height: 30)
        //设置用户名称布局
        fullnameLabel.frame = CGRect(x: avaImg.frame.origin.x, y: avaImg.frame.origin.y + avaImg.frame.height, width: width - 30, height: 30)
        
        webTxt.frame = CGRect(x: avaImg.frame.origin.x - 5, y: fullnameLabel.frame.origin.y + 20, width: width - 30, height: 30)
        
        bioLbl.frame = CGRect(x: avaImg.frame.origin.x, y: webTxt.frame.origin.y + 20, width: width - 30, height: 30)

    }
}
