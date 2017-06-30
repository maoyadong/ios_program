//
//  HomeVC.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/9.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AVOSCloudIM
import AVOSCloudCrashReporting

class HomeVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    //刷新控件
    var refresher: UIRefreshControl!
    //每页载入帖子的数量
    var page: Int = 12
    var puuidArray = [String]()
    var picArray = [AVFile]()
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置集合视图在垂直方向有反弹的效果
        self.collectionView?.alwaysBounceVertical  = true

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.title = AVUser.current()?.username?.uppercased()
        

        // Do any additional setup after loading the view.
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        //从EditVC类接收Notification
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        //从UploadVc接收Notification
        NotificationCenter.default.addObserver(self, selector: #selector(uploaded(notification:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        loadPosts()
    }

    func uploaded(notification: Notification) {
        loadPosts()
    }
    func reload(notification: Notification) {
        collectionView?.reloadData()
    }
    func refresh() {
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    
    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: AVUser.current()?.username as Any)
        query.limit = page
        query.findObjectsInBackground({ (object:[Any]?, error:Error?) in
            //清空两个数组
            if error == nil {
                self.puuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                for object in object! {
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                }
                self.collectionView?.reloadData()
            } else {
                print(error?.localizedDescription as Any)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return picArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        header.fullnameLabel.text = (AVUser.current()?.object(forKey: "fullname") as? String)?.uppercased()
        header.webTxt.text = AVUser.current()?.object(forKey: "web") as? String
        header.webTxt.sizeToFit()
        header.bioLbl.text = AVUser.current()?.object(forKey: "bio") as? String
        header.bioLbl.sizeToFit()
        
        //从服务器获取头像数据
        let avaQuery = AVUser.current()?.object(forKey: "ava") as! AVFile
        avaQuery.getDataInBackground{ (data:Data?, error:Error?) in
            if data == nil {
                print(error?.localizedDescription as Any)
            } else {
            header.avaImg.image = UIImage(data: data!)
            }
        }
        
        //帖子数
        let currentUser: AVUser = AVUser.current()!
        let postsQuery = AVQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: currentUser.username!)
        postsQuery.countObjectsInBackground({ (count:Int, error:Error?) in
            if error == nil {
                header.posts.text = String(count)
            }
        })
        
        //关注者
        let followersQuery = AVQuery(className: "_Follower")
        followersQuery.whereKey("user", equalTo: currentUser)
        followersQuery.countObjectsInBackground({ (count:Int,error:Error?) in
            if error == nil {
                header.follwers.text = String(count)
                
            }
        })
        
        //关注
        let followeesQuery = AVQuery(className: "_Followee")
        followeesQuery.whereKey("user", equalTo: currentUser)
        followeesQuery.countObjectsInBackground({ (count:Int,error:Error?) in
            if error == nil {
                header.followings.text = String(count)
            }
        })
        
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
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        picArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription as Any)
            }
        }
        // Configure the cell
    
        return cell
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
    
    //点击HomeVC右上角叉叉的调用事件
    @IBAction func logout(_ sender: Any) {
        //退出用户登录
        AVUser.logOut()
        
        //从UserDefaults中移除用户登录记录
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.synchronize()
        
        //设置rootViewController为登录控制器
        let signIn = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = signIn
    }
    
    //设置单元格大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAt indexPath:IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width / 3, height: self.view.frame.height / 3)
        return size
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
            query.whereKey("username", equalTo: AVUser.current()?.username as Any)
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
