//
//  PostCell.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/25.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AVOSCloudIM

class PostCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    //帖子照片
    @IBOutlet weak var picImg: UIImageView!
    
    //按钮
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var titleLbl: KILabel!
    @IBOutlet weak var puuidLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let width = UIScreen.main.bounds.width
        //启动约束
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false

        picImg.translatesAutoresizingMaskIntoConstraints = false
        likeBtn.translatesAutoresizingMaskIntoConstraints = false
        commentBtn.translatesAutoresizingMaskIntoConstraints = false
        moreBtn.translatesAutoresizingMaskIntoConstraints = false
        likeLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        puuidLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let picWidth = width - 20
        //约束
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[ava(30)]-10-[pic(\(picWidth))]-5-[like(30)]", options: [], metrics: nil, views: ["ava": avaImg, "pic": picImg, "like": likeBtn]))
        //垂直方向上距离顶部10个点事usernameBtn
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[username]", options: [], metrics: nil, views: ["username": usernameBtn]))
        //垂直方向距离底部5个点事commentBtn
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[pic]-5-[comment(30)]", options: [], metrics: nil, views: ["pic": picImg, "comment": commentBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[date]", options: [], metrics: nil, views: ["date": dateLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[like]-5-[title]-5-|", options: [], metrics: nil, views: ["like": likeBtn,"title": titleLbl]))

        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[pic]-5-[more(30)]", options: [], metrics: nil, views: ["pic": picImg, "more": moreBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[pic]-10-[likes]", options: [], metrics: nil, views: ["pic": picImg, "likes": likeLbl]))
        
        //水平约束
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[ava(30)]-10-[username]", options: [], metrics: nil, views: ["ava": avaImg, "username": usernameBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic]-10-|", options: [], metrics: nil, views: ["pic": picImg]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[like(30)]-10-[likes]-20-[comment(30)]", options:[] , metrics: nil, views: ["like": likeBtn, "likes": likeLbl, "comment": commentBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[more(30)]-15-|", options:[] , metrics: nil, views: ["more": moreBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[title]-15-|", options:[] , metrics: nil, views: ["title": titleLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[date]-10-|", options:[] , metrics: nil, views: ["date": dateLbl]))
        
        //设置用户头像为圆形
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        
        //将liked的文字设置为无色
        likeBtn.setTitleColor(.clear, for: .normal)
        
        //双击照片添加喜爱
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeTap.numberOfTapsRequired = 2
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(likeTap)
    }
    
    func likeTapped() {
        //创建一个大的红色桃心
        let likePic = UIImageView(image: UIImage(named: "like.png"))
        likePic.frame.size.width = picImg.frame.width / 1.5
        likePic.frame.size.height = picImg.frame.height / 1.5
        likePic.center = picImg.center
        likePic.alpha = 0.8
        self.addSubview(likePic)
        UIView.animate(withDuration: 1, animations: {
            likePic.alpha = 0
            likePic.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        })
        
        let title = likeBtn.title(for: .normal)
        if title == "unlike" {
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.username
            object["to"] = puuidLbl.text
            object.saveInBackground({ (success: Bool, error: Error?) in
                if success {
                    print("标记为: like!")
                    self.likeBtn.setTitle("like", for: .normal)
                    self.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
                    //如果设置为喜爱，则发送通知给表格视图刷新表格
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                }
            })
        }
    }
    //喜欢按钮的点击
    @IBAction func likeBtn_clicked(_ sender: AnyObject) {
        //获取likeBtn按钮的Title
        let title = sender.title(for: .normal)
        if title == "unlike" {
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.username
            object["to"] = puuidLbl.text
            object.saveInBackground({ (success: Bool, error: Error?) in
                if success {
                    print("标记为: like!")
                    self.likeBtn.setTitle("like", for: .normal)
                    self.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
                    //如果设置为喜爱，则发送通知给表格视图刷新表格
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                }
            })
        } else {
            //搜索Likes表中对应的记录
            let query = AVQuery(className: "Likes")
            query.whereKey("by", equalTo: AVUser.current()?.username as Any)
            query.whereKey("to", equalTo: puuidLbl.text as Any)
            query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                for object in objects! {
                    (object as AnyObject).deleteInBackground({ (success: Bool, error: Error?) in
                        if success {
                            print("删除like记录,disliked")
                            self.likeBtn.setTitle("unlike", for: .normal)
                            self.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: .normal)
                            
                            //如果设置为喜爱，则发送通知给表格视图刷新表格
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                        }
                    })
                }
            })
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
