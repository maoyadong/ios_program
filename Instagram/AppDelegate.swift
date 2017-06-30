//
//  AppDelegate.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/4.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AVOSCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UICollectionViewDelegate {

    var window: UIWindow?

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        AVOSCloud.setApplicationId("8I98jPPGyGCYKeJD7sNCaJGa-gzGzoHsz",clientKey:"30TIDaa4itycJi5UzrUrC7os")
        AVAnalytics.trackAppOpened(launchOptions: launchOptions)
        window?.backgroundColor = .white
        login()    //有了之前的用户注册操作，所以App一启动就直接进入到了TabBarController
        return true
    }
    
    
    func login() {
        let username: String? = UserDefaults.standard.string(forKey: "username")
        if username != nil {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let myTabBar = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
            window?.rootViewController = myTabBar
//            AVUser.current()?.follow("594b7b600ce463005745a3dc") { (success:Bool, error:Error?) in
//                if success {
//                    print("为当前用户添加关注者成功")
//                } else {
//                    print("为当前用户添加关注者失败")
//                }
//            }
            
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

