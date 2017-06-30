//
//  CommentVC.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/26.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AVOSCloudIM

var commentuuid = [String]()
var commentowner = [String]()

class CommentVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    var refresher = UIRefreshControl()
    var keyboard = CGRect()
    var tableViewHeight: CGFloat = 0    //控制器表格的高度
    var commentY: CGFloat = 0
    var commentHeight: CGFloat = 0
    
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    var commentArray = [String]()
    var dateArray = [Date]()
    
    var page: Int = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alignment()
        loadComments()
        // Do any additional setup after loading the view.
        //如果键盘出现或消失，捕获这两个消息
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func alignment() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height / 1.096 - self.navigationController!.navigationBar.frame.height - 20)
        tableView.estimatedRowHeight = width / 5.33
        tableView.rowHeight = UITableViewAutomaticDimension
        
        commentTxt.frame = CGRect(x: 10, y: tableView.frame.height + height / 56.8, width: width / 1.306, height: 33)
        commentTxt.layer.cornerRadius = commentTxt.frame.width / 50       //评论框是圆边
        
        sendBtn.frame = CGRect(x: commentTxt.frame.origin.x + commentTxt.frame.width + width / 32, y: commentTxt.frame.origin.y, width: width - (commentTxt.frame.origin.x + commentTxt.frame.width) - width / 32 * 2, height: commentTxt.frame.height)
        tableViewHeight = tableView.frame.height
        commentHeight = commentTxt.frame.height
        commentY = commentTxt.frame.origin.y
        
        self.navigationItem.title = "评论"
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //在开始的时候，禁止sendBtn按钮
        self.sendBtn.isEnabled = false
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)
        
        commentTxt.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    //当输入的时候回调动这个方法
    func textViewDidChange(_ textView: UITextView) {
        //如果没有输入信息则禁止按钮
        //出去空格或者换行
        let spacing = CharacterSet.whitespacesAndNewlines
        if !commentTxt.text.trimmingCharacters(in: spacing).isEmpty {
            sendBtn.isEnabled = true
        } else {
            sendBtn.isEnabled = false
        }
        if textView.contentSize.height > textView.frame.height && textView.frame.height < 130 {
            let difference = textView.contentSize.height - textView.frame.height
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            //将tableView的下边上移
            if tableView.contentSize.height + keyboard.height + commentY >= tableView.frame.height {
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        } else if textView.contentSize.height < textView.frame.height {
            let difference = textView.frame.height - textView.contentSize.height
            
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            //tableView下移
            if textView.contentSize.height + keyboard.height + commentY > tableView.frame.height {
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
        
    }
    func keyboardWillShow(_ notification: Notification) {
        //获取到键盘的大小
        let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]!) as! NSValue
        keyboard = rect.cgRectValue
        
        UIView.animate(withDuration: 0.4, animations: {() -> Void in
            self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height
            self.commentTxt.frame.origin.y = self.commentY - self.keyboard.height
            self.sendBtn.frame.origin.y = self.commentTxt.frame.origin.y
            
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.4, animations: {() -> Void in
            self.tableView.frame.size.height = self.tableViewHeight
            self.commentTxt.frame.origin.y = self.commentY
            self.sendBtn.frame.origin.y = self.commentY
        })
    }
    func back(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
        //从数组中清除评论的uuid
        if !commentuuid.isEmpty {
            commentuuid.removeLast()
        }
        //从数组中清除评论所有者
        if !commentowner.isEmpty {
            commentowner.removeLast()
        }
        
    }

    //发送按钮
    @IBAction func sendBtn_clicked(_ sender: Any) {
        //在表格视图中添加一行
        usernameArray.append((AVUser.current()?.username)!)
        avaArray.append(AVUser.current()?.object(forKey: "ava") as! AVFile)
        dateArray.append(Date())
        commentArray.append(commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        tableView.reloadData()
        
        //发送评论到云端
        let commentObj = AVObject(className: "Comments")
        commentObj["to"] = commentuuid.last!
        commentObj["username"] = AVUser.current()?.username
        commentObj["ava"] = AVUser.current()?.object(forKey: "ava")
        commentObj["comment"] = commentTxt.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        commentObj.saveEventually()
        
        //发送hashtag到云端
        //将文字信息划分成独立的字符串,分割的依据是下划线或换行
        let words: [String] = commentTxt.text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            //定义正则表达式
            let patterrn = "#[^#]+"
            let regular = try! NSRegularExpression(pattern: patterrn, options: .caseInsensitive)
            let results = regular.matches(in: word, options: .reportProgress, range: NSMakeRange(0, word.characters.count))
            //输出截取结果
            print("符合的结果有\(results.count)个")
            for result in results {
                word = (word as NSString).substring(with: result.range)
            }
            
            if word.hasSuffix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
            }
        }
        
    
        //scroll to bottom
        self.tableView.scrollToRow(at: IndexPath(item: commentArray.count - 1, section:0), at: .bottom, animated: false)
        
        //重置UI
        commentTxt.text = ""
        commentTxt.frame.size.height = commentHeight
        commentTxt.frame.origin.y = sendBtn.frame.origin.y
        tableView.frame.size.height = tableViewHeight - keyboard.height - commentTxt.frame.size.height + commentHeight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //隐藏底部标签栏
        self.tabBarController?.tabBar.isHidden = true
        //调出键盘
        self.commentTxt.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    //给指定位置的单元格预估一个高度
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentCell
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.usernameBtn.sizeToFit()
        cell.commentLbl.text = commentArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            cell.avaImg.image = UIImage(data: data!)
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
        
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        //@  实现与label的交互操作
        cell.commentLbl.userHandleLinkTapHandler = { label, handle, rang in
            var mention = handle
            //
            mention = String(mention.characters.dropFirst())
            if mention.lowercased() == AVUser.current()?.username {
                let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                self.navigationController?.pushViewController(home, animated: true)
            } else {
                let query = AVUser.query()
                query.whereKey("username", equalTo: mention.lowercased())
                query.findObjectsInBackground({ (objects:[Any]?, error: Error?) in
                    if let object = objects?.last {
                        guestArray.append(object as! AVUser)
                        let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                        self.navigationController?.pushViewController(guest, animated: true)
                    }
                })
            }
        }
        return cell
    }
    
    func loadComments() {
        //合计出所有评论的数量
        let countQuery = AVQuery(className: "Comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground({ (count:Int, error: Error?) in
            if self.page < count {
                self.refresher.addTarget(self, action: #selector(self.loadMore), for: .valueChanged)
                self.tableView.addSubview(self.refresher)
            }
            
            //获取最新的self.page数量的评论
            let query = AVQuery(className: "Comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createAt")
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil {
                    //请空数组
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        self.usernameArray.append((object as AnyObject).object(forKey: "username") as! String)
                        self.avaArray.append((object as AnyObject).object(forKey: "ava") as! AVFile)
                        self.commentArray.append((object as AnyObject).object(forKey: "comment") as! String)
                        self.dateArray.append((object as AnyObject).createdAt!!)
                        self.tableView.reloadData()
                        self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0), at: .bottom, animated: true)
                    }
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
        })
    }
    
    func loadMore() {
        //合计出所有评论的数量
        let countQuery = AVQuery(className: "Comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground({ (count:Int, error: Error?) in
            //让refresh停止刷新动画
            self.refresher.endRefreshing()
            if self.page >= count {
                self.refresher.removeFromSuperview()
            }
            //载入更多的评论
            if self.page < count {
                self.page = self.page + 15
                
                //从云端查询page的个记录
                let query = AVQuery(className: "Comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count - self.page
                query.addAscendingOrder("createAt")
                query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                    if error == nil {
                        //请空数组
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        
                        for object in objects! {
                            self.usernameArray.append((object as AnyObject).object(forKey: "username") as! String)
                            self.avaArray.append((object as AnyObject).object(forKey: "ava") as! AVFile)
                            self.commentArray.append((object as AnyObject).object(forKey: "comment") as! String)
                            self.dateArray.append((object as AnyObject).createdAt!!)
                        }
                        self.tableView.reloadData()
                    } else {
                        print(error?.localizedDescription as Any)
                    }
                })
            }
        })
    }
    
    @IBAction func usernameBtn_clicked(_ sender: AnyObject) {
        //按钮的index
        let i = sender.layer.value(forKey: "index") as! IndexPath
        //通过i获取到用户所单击的单元格
        let cell = tableView.cellForRow(at: i) as! CommentCell
        //如果当前用户单击的是自己的username，则调用HomeVC，否则是Guest
        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameBtn.titleLabel?.text as Any)
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if let object = objects?.last {
                    guestArray.append(object as! AVUser)
                    
                    let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                    self.navigationController?.pushViewController(guest, animated: true)
                }
            })
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //获取到用户所滑动的单元格
        let cell = tableView.cellForRow(at: indexPath) as! CommentCell
        
        //删除操作
        let delete = UITableViewRowAction(style: .normal, title: "删除") {(UITableViewRowAction, IndexPath) ->Void in
            //从云端删除评论
            let commentQuery = AVQuery(className: "Comments")
            commentQuery.whereKey("to", equalTo: commentuuid.last as Any)
            commentQuery.whereKey("comment", equalTo: cell.commentLbl.text as Any)
            commentQuery.findObjectsInBackground({ (objects:[Any]?, error: Error?) in
                if error == nil {
                    //找到相关记录
                    for object in objects! {
                        (object as AnyObject).deleteEventually()
                    }
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
            
            //从表格删除评论
            self.commentArray.remove(at: indexPath.row)
            self.dateArray.remove(at: indexPath.row)
            self.avaArray.remove(at: indexPath.row)
            self.usernameArray.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            //关闭可操作状态
            self.tableView.setEditing(false, animated: true)
        }
        
        //@Address
        let address = UITableViewRowAction(style: .normal, title: "喊话") {(UITableViewRowAction, indexPath) -> Void in
            //在Text View中包含Address
            self.commentTxt.text = "\(self.commentTxt.text + "@" + self.usernameArray[indexPath.row] + " ")"
            //让按钮生效
            self.sendBtn.isEnabled = true
            //关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }
        
        //投诉
        let complain = UITableViewRowAction(style: .normal, title: "投诉") {(UITableViewRowAction, indexPath) -> Void in
            //发送投诉到云端
            let complainObj = AVObject(className: "Complain")
            complainObj["by"] = AVUser.current()?.username
            complainObj["post"] = commentuuid.last
            complainObj["to"] = cell.commentLbl.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            
            complainObj.saveInBackground({ (success:Bool, error: Error?) in
                if success {
                    self.alert(error: "投诉成功", message: "投诉信息已经发送")
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
            self.tableView.setEditing(false, animated: true)
        }
        
        //按钮的背景颜色
        delete.backgroundColor = .red
        address.backgroundColor = .green
        complain.backgroundColor = .yellow
        
        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username {
            return [delete, address]
        } else if commentowner.last == AVUser.current()?.username {
            return [delete, address, complain]
        } else {
            return [address, complain]
        }
        
    }
    
    func alert(error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

}
