//
//  PostVC.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/25.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AVOSCloudIM

var postuuid = [String]()
class PostVC: UITableViewController {

    //从服务器获取相应的数据后写入到相应的数组中
    var avaArray = [AVFile]()
    var usernameArray = [String]()
    var dateArray = [Date]()
    var picArray = [AVFile]()
    var puuidArray = [String]()
    var titleArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //定义新的返回按钮
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //向右滑动屏幕回到之前的控制器
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)
        
        //动态单元格的高度
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        let postQuery = AVQuery(className: "Posts")
        postQuery.whereKey("puuid", equalTo: postuuid.last!)
        postQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
            //清空数组
            self.avaArray.removeAll(keepingCapacity: false)
            self.usernameArray.removeAll(keepingCapacity: false)
            self.dateArray.removeAll(keepingCapacity: false)
            self.picArray.removeAll(keepingCapacity: false)
            self.puuidArray.removeAll(keepingCapacity: false)
            self.titleArray.removeAll(keepingCapacity: false)
            
            for object in objects! {
                self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                self.usernameArray.append((object as AnyObject).value(forKey: "username") as! String)
                self.dateArray.append((object as AnyObject).createdAt!!)
                self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                self.titleArray.append((object as AnyObject).value(forKey: "title") as! String)

            }
            //闭包中的代码是在其他线程中进行的，如果没有reload这句代码，则不会显示任何数据
            self.tableView.reloadData()
        })
        
        //接收到来自Postcell中的liked通知
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name.init(rawValue: "liked"), object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func back(_ sender: UIBarButtonItem) {
        //退回到之前
        _ = self.navigationController?.popViewController(animated: true)
        //从postuuid数组中移除当前帖子的uuid
        if !postuuid.isEmpty {
            postuuid.removeLast()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell

        //通过数组信息关联单元格中的UI控件
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.puuidLbl.text = puuidArray[indexPath.row]
        cell.titleLbl.text = titleArray[indexPath.row]
        
        cell.titleLbl.sizeToFit()
        cell.usernameBtn.sizeToFit()
        //配置用户头像
        avaArray[indexPath.row].getDataInBackground{ (data: Data?, error: Error?) in
            cell.avaImg.image = UIImage(data: data!)
        }
        
        //配置帖子照片
        picArray[indexPath.row].getDataInBackground{ (data: Data?, error: Error?) in
            cell.picImg.image = UIImage(data: data!)
        }
        
        //创建时间与当前时间的间隔差
        let from = dateArray[indexPath.row]
        //获取当前的时间
        let now = Date()
        //创建日历相关的set集合
        let components : Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = Calendar.current.dateComponents(components, from: from, to: now)
        
        if difference.second! <= 0 {
            cell.dateLbl.text = "刚刚"
        }
        
        if difference.second! > 0 && difference.minute! <= 0 {
            cell.dateLbl.text = "\( difference.second!)秒前"
        }
        if difference.minute! > 0 && difference.hour! <= 0 {
            cell.dateLbl.text = "\(difference.minute!)分钟前"
        }
        if difference.hour! > 0 && difference.day! <= 0 {
            cell.dateLbl.text = "\(difference.hour!)小时前"
        }
        if difference.day! > 0 && difference.weekOfMonth! <= 0 {
            cell.dateLbl.text = "\(difference.day!)天前"
        }
        if difference.weekOfMonth! > 0 {
            cell.dateLbl.text = "\(difference.weekOfMonth!)周前"
        }
        
        //根据用户是否喜欢来维护喜欢按钮按钮
        let didLike = AVQuery(className: "Likes")
        didLike.whereKey("by", equalTo: AVUser.current()?.username as Any)
        didLike.whereKey("to", equalTo: cell.puuidLbl.text as Any)
        didLike.countObjectsInBackground({ (count: Int?, error: Error?) in
            if count == 0 {
                cell.likeBtn.setTitle("unlike", for: .normal)
                cell.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: .normal)
            } else {
                cell.likeBtn.setTitle("like", for: .normal)
                cell.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
            }
        })
        
        //计算本帖子的喜爱总数
        let countlike = AVQuery(className: "Likes")
        countlike.whereKey("to", equalTo: cell.puuidLbl.text as Any)
        countlike.countObjectsInBackground({ (count: Int?, error: Error?) in
            cell.likeLbl.text = "\(count ?? 0)"
        })
        // Configure the cell...
        
        //将indexPath赋值给usernameBtn的layer属性的自定义变量
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        //将indexPath的值赋给commentBtn的layer属性的自定义变量
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        
        //将indexPath的值赋给moreBtn的layer属性的自定义变量
        cell.moreBtn.layer.setValue(indexPath, forKey: "index")
        return cell
    }
    
    //设置当PostVC接收到liked通知后，执行refresh方法
    

    func refresh() {
        self.tableView.reloadData()
    }
    
    
    @IBAction func usernameBtn_clicked(_ sender: AnyObject) {
        //按钮的index
        let i = sender.layer.value(forKey: "index") as! IndexPath
        //通过i获取当前用户所单击的单元格
        let cell = tableView.cellForRow(at: i) as! PostCell
        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    @IBAction func commentBtn_clicked(_ sender: AnyObject) {
        
        let i = sender.layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! PostCell
        commentuuid.append(cell.puuidLbl.text!)
        commentowner.append(cell.usernameBtn.titleLabel!.text!)
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    @IBAction func moreBtn_clicked(_ sender: AnyObject) {
        let i = sender.layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        //删除操作
        let delete = UIAlertAction(title: "删除", style: .default) {(UIAlertAction)->Void in
            //从数组中删除相应的数据
            self.usernameArray.remove(at: i.row)
            self.avaArray.remove(at: i.row)
            self.picArray.remove(at: i.row)
            self.dateArray.remove(at: i.row)
            self.puuidArray.remove(at: i.row)
            self.titleArray.remove(at: i.row)
            
            //删除云端的数据
            let postQuery = AVQuery(className: "Posts")
            postQuery.whereKey("puuid", equalTo: cell.puuidLbl.text as Any)
            postQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteInBackground({ (success: Bool, error: Error?) in
                            if success {
                                //发送通知到rootViewController更新帖子
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                                
                                //销毁当前控制器
                                _ = self.navigationController?.popViewController(animated: true)
                            } else {
                                print(error?.localizedDescription as Any)
                            }
                        })
                    }
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
            
            //删除Like记录
            let likeQuery = AVQuery(className: "Likes")
            likeQuery.whereKey("to", equalTo: cell.puuidLbl.text as Any)
            likeQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                for object in objects! {
                    (object as AnyObject).deleteEventually()
                }
            })
            
            //删除commments记录
            let commentQuery = AVQuery(className: "Comments")
            commentQuery.whereKey("to", equalTo: cell.puuidLbl.text as Any)
            commentQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                for object in objects! {
                    (object as AnyObject).deleteEventually()
                }
            })
            
        }
        
        let complain = UIAlertAction(title: "投诉", style: .default) {(UIAlertAction) -> Void in
            //发送投诉到云端的Complain数据表
            let complainObject = AVObject(className: "Complain")
            complainObject["by"] = AVUser.current()?.username
            complainObject["post"] = cell.puuidLbl.text
            complainObject["to"] = cell.titleLbl.text
            complainObject["owner"] = cell.usernameBtn.titleLabel?.text
            complainObject.saveInBackground({ (success: Bool, error: Error?) in
                if success {
                    
                }
            })
        }
        
        //取消操作
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        //擦混关键菜单控制器
        let menu = UIAlertController(title: "菜单选项", message: nil, preferredStyle: .actionSheet)
        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username {
            menu.addAction(delete)
            menu.addAction(cancel)
        } else {
            menu.addAction(complain)
            menu.addAction(cancel)
        }
        
        self.present(menu, animated: true, completion: nil)
        
    }
    
    func alert(error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
