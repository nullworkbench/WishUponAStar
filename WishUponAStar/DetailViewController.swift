//
//  DetailViewController.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/03/09.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class DetailViewController: UIViewController {
    
    // AppDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Firestore
    var db: Firestore!
    
    var direction: Float!
    var wish: String!
    var createdAt: Date!
    var uid: String!
    var docId: String!
    
    @IBOutlet var wishLabel: UILabel!
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var uidLabel: UILabel!
    @IBOutlet var reportButton: UIButton!
    @IBOutlet var blockButton: UIButton!
    @IBOutlet var deleteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        wishLabel.text = wish
        directionLabel.text = String(format: "%.01f", Float(direction)) + " " + judgeDirection(Float(direction))
        createdAtLabel.text = stringFromDate(date: createdAt, format: "yyyy/MM/dd HH:mm:ss")
        uidLabel.text = uid
        
        // 投稿が自分のものかによってボタンを切り替え
        if uid == appDelegate.user?.uid {
            reportButton.isHidden = true
            blockButton.isHidden = true
        } else {
            deleteButton.isHidden = true
        }
        
        // Firestore
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
    }
    
    // 前画面のViewWillAppear, ViewDidAppearが実行されるように
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
    }
    
    
    func blockUser() {
        // blockedUidsArrayがあるか
        if var blockedUidsArray = UserDefaults.standard.array(forKey: "blockedUidsArray") {
            // 対象のUidを追加
            blockedUidsArray.append(uid!)
            UserDefaults.standard.set(blockedUidsArray, forKey: "blockedUidsArray")
        } else {
            // 新規に作成
            var blockedUidsArray = [String]()
            // 対象のUidを追加
            blockedUidsArray.append(uid!)
            UserDefaults.standard.set(blockedUidsArray, forKey: "blockedUidsArray")
        }
    }
    
    
    @IBAction func report() {
        let alert = UIAlertController(title: "この投稿を通報しますか？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "通報する", style: .destructive, handler: { action in
    //        let reason = "不快になる発言"
            let urlString = "https://docs.google.com/forms/d/e/1FAIpQLScDPxGdvUKeWGv71GCppEZW83gIKSi7SHOgETRSFrfBvaUn3g/viewform?usp=pp_url&entry.758198942=\(self.docId!)"
            let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) // 日本語をURLに含めるためエンコード
            let formUrl = URL(string: encodedUrlString!)
            UIApplication.shared.open(formUrl!) // Safariで開く
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func block() {
        let alert = UIAlertController(title: "本当にブロックしますか？", message: "ブロックしたユーザーの投稿は今後表示されません。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "ブロック", style: .destructive, handler: {action in
            // ブロック処理
            self.blockUser()
            self.dismiss()
        }))
        present(alert, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func deletePost() {
        let alert = UIAlertController(title: "本当に削除しますか？", message: "削除した投稿は復元できません。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {action in
            self.db.collection("posts").document(self.docId).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
                self.dismiss()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
