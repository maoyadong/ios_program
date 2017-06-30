//
//  GuestVC.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/23.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AVOSCloudIM

var guestArray = [AVUser]()        //定义一个全局变量数组 AVUser类型



class GuestVC: UICollectionViewController {

    //从云端获取数据并存储到数组中
    var puuidArray = [String]()
    var picArray = [AVFile]()
    
    //界面对象
    var refresher:UIRefreshControl!
    var page: Int = 12
    override func viewDidLoad() {
        super.viewDidLoad()
        //允许垂直的拉拽刷新操作
        self.collectionView?.alwaysBounceVertical = true
        //导航栏的顶部信息
        self.navigationController?.title = guestArray.last?.username
        //设置背景颜色为白色
        self.collectionView?.backgroundColor = .white
        self.navigationItem.title = guestArray.last?.username
        //定义导航栏中新的返回按钮
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //实现向右滑动返回
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.addGestureRecognizer(backSwipe)
        
        //安装refresh控件
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView?.addSubview(refresher)
        
        loadPosts()
    }

    func back(_: UIBarButtonItem) {
        //退回到之前的控制器   _表示以后绝对不会用到
        _ = self.navigationController?.popViewController(animated: true)
        
        //从guestArray中移除最后一个AVUser
        if !guestArray.isEmpty {
            guestArray.removeLast()
        }
    }
    
    //刷新方法
    func refresh() {
        self.collectionView?.reloadData()
        self.refresher.endRefreshing()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //点击关注按钮
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return picArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
    
        // Configure the cell
        //定义Cell
        picArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            if error == nil {
                cell.picImg.image = UIImage(data:data!)
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    
        return cell
    }

    //载入访客发布的帖子
    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: guestArray.last?.username)
        query.limit = page
        query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
            if error == nil {
                //清空两个数组
                self.puuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    //将查询到的结果添加到数组中
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                }
                
                self.collectionView?.reloadData()
            } else {
                print(error?.localizedDescription as Any)
            }
        })
    }
    
    
    //添加一个补充视图
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //定义header
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        //第一步。载入访客的基本数据信息
        let infoQuery = AVQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestArray.last?.username as Any)
        
        print("guestArray.last?.username")
        print(guestArray.last?.username as Any)
        
        infoQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
            if error == nil {
                guard let objects = objects, objects.count > 0 else {
                    let alert = UIAlertController(title: "\(guestArray.last?.username)", message: "没有发现该用户", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                for object in objects {
                
                    header.fullnameLabel.text = ((object as AnyObject).object(forKey: "fullname") as? String)?.uppercased()
                    header.bioLbl.text = (object as AnyObject).object(forKey: "bio") as? String
                    header.bioLbl.sizeToFit()
                    header.webTxt.text = (object as AnyObject).object(forKey: "web") as? String
                    header.webTxt.sizeToFit()
                    
                    let avaFile = (object as AnyObject).object(forKey: "ava") as? AVFile
                    avaFile?.getDataInBackground({ (data:Data?,error:Error?) in
                        header.avaImg.image = UIImage(data: data!)
                    })
                }
            } else {
                print(error?.localizedDescription as Any)
            }
            
        })
        
        //第二步，设置当前用户和访客之间的关注状态
        let followeeQuery = AVUser.current()?.followeeQuery()
        followeeQuery?.whereKey("user", equalTo: AVUser.current()!)
        
    
        followeeQuery?.whereKey("followee", equalTo: guestArray.last as Any)
        
        followeeQuery?.countObjectsInBackground ({ (count:Int?, error:Error?) in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                    return
            }
            if count == 0 {
                header.button.setTitle("关 注", for: .normal)
                header.button.backgroundColor = .lightGray
            } else {
                header.button.setTitle("√ 已关注 ", for: .normal)
                header.button.backgroundColor = .green
            }

        })
        
        //第三步，计算统计数据
        //访客的帖子数
        let posts = AVQuery(className: "Posts")
        posts.whereKey("username", equalTo: guestArray.last?.username as Any)
        posts.countObjectsInBackground({ (count:Int, error:Error?) in
            if error == nil {
                print("访客的帖子数运行了/(count)")
                header.posts.text = String(count)
                
            } else {
                print("访客的帖子数没有运行")
                print(error?.localizedDescription as Any)
            }
        })
        
        //访客的关注者数
        let followers = AVUser.followerQuery((guestArray.last?.objectId)!)
        followers.countObjectsInBackground({ (count:Int,error:Error?) in
            if error == nil {
                header.follwers.text = String(count)
            } else {
                print(error?.localizedDescription as Any)
            }
        })
        
        //访客的关注数
        let followings = AVUser.followeeQuery((guestArray.last?.objectId)!)
        followings.countObjectsInBackground({ (count:Int,error:Error?) in
            if error == nil {
                header.followings.text = String(count)
            } else {
                print(error?.localizedDescription as Any)
            }
        })
        
        //第四步，实现统计数据的单击手势
        //单击帖子数
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTap(_:)))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        //单击关注者数
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTap(_:)))
        followersTap.numberOfTapsRequired = 1
        header.follwers.isUserInteractionEnabled = true
        header.follwers.addGestureRecognizer(followersTap)
        
        //单击关注数
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(folllowingsTap(_:)))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
    
        return header
    }
    
    //点击帖子后的使用方法
    func postsTap(_ recognizer:UITapGestureRecognizer)
    {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            //指定位置的单元
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
            
        }
        
    }
    
    //点击关注者数后的使用方法
    func followersTap(_ recognizer:UITapGestureRecognizer)
    {
        //从故事版中载入FollowersVC的视图
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followers.user = (AVUser.current()?.username)!
        followers.show = "关 注 者"
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    //点击关注数后的使用方法
    func folllowingsTap(_ recognizer:UITapGestureRecognizer)
    {
        //从故事版载入FollowersVC的视图
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followings.user = (AVUser.current()?.username)!
        followings.show = "关 注"
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.height {
            loadMore()
        }
    }
    
    func loadMore() {
        if page <= picArray.count {
            page = page + 12
            let query = AVQuery(className: "Posts")
            query.whereKey("username", equalTo: guestArray.last?.username)
            query.limit = page
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                //查询成功
                if error == nil {
                    //清空两个数组
                    self.puuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    for object in objects! {
                        self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                        self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                    }
                    print("loaded + \(self.page)")
                    self.collectionView?.reloadData()
                }
                print(error?.localizedDescription as Any)
            })
        }
    }
    
    //选中单元格会跳转到PostVC上
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postuuid.append(puuidArray[indexPath.row])
        
        //导航到postVC控制器
        let postVC = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
