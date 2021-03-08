//
//  AppDelegate.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/02/22.
//

import UIKit

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // FirestoreのsnapshotListenerインスタンス保持用
    var listener: ListenerRegistration? = nil
    
    // Firebase Authの認証状態リスナー
    var authHandle: AuthStateDidChangeListenerHandle?
    
    // Firebase Auth user
    var user: User?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Firebase config
        FirebaseApp.configure()
        
        // Firestore
        let db = Firestore.firestore()
        print(db)
        
        // Firebase Auth
        if Auth.auth().currentUser != nil {
            // ログイン済
            user = Auth.auth().currentUser
            print("ログイン済。uid: \(user!.uid)")
        } else {
            // 未ログイン
            Auth.auth().signInAnonymously(completion: {(authResult, err) in
                self.user = authResult?.user
                let uid = self.user!.uid
                print("ログイン成功。uid: \(uid)")
            })
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // アプリを完全に終了しようとするとき
    func applicationWillTerminate(_ application: UIApplication) {
        // FirestoreのsnapshotListenerを解除
        listener?.remove()
    }


}

