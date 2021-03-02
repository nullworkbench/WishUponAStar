//
//  ListViewController.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/03/01.
//

import UIKit

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class ListViewController: UIViewController, UITableViewDataSource {
    
    var postsArray: [Post] = []
    
    // Firestore
    var db: Firestore!
    
    @IBOutlet var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        table.dataSource = self
        
        //Firestore
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        
        // 最新50件を取得
        db.collection("posts").order(by: "createdAt", descending: true).limit(to: 50).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                // すべての投稿をpostsArrayへ格納
                for document in querySnapshot!.documents {
                    let data = document.data()
                    self.postsArray.append(Post(wish: data["wish"] as! String,
                                           direction: data["direction"] as! Float,
                                           date: (data["createdAt"] as! Timestamp).dateValue()
                    ))
                }
                // FirestoreのクエリがtableViewの描画開始に間に合わないため再読み込み
                self.table.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let wishLabel = cell?.viewWithTag(1) as! UILabel
        let directionLabel = cell?.viewWithTag(2) as! UILabel
        let dateLabel = cell?.viewWithTag(3) as! UILabel
        
        wishLabel.text = postsArray[indexPath.row].wish
        directionLabel.text = self.judgeDirection(postsArray[indexPath.row].direction)
        dateLabel.text = stringFromDate(date: postsArray[indexPath.row].date, format: "yyyy/MM/dd HH:mm:ss")
        
        return cell!
    }
    
    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    

}

class Post {
    var wish: String!
    var direction: Float!
    var date: Date!
    
    init(wish: String, direction: Float, date: Date) {
        self.wish = wish
        self.direction = direction
        self.date = date
    }
}

extension ListViewController {
    func judgeDirection(_ direction: Float) -> String {
        if direction > 22 && direction <= 67 {
            return "北東"
        } else if direction > 67 && direction <= 112 {
            return "東"
        } else if direction > 112 && direction <= 157 {
            return "南東"
        } else if direction > 157 && direction <= 202 {
            return "南"
        } else if direction > 202 && direction <= 247 {
            return "南西"
        } else if direction > 247 && direction <= 292 {
            return "西"
        } else if direction > 292 && direction <= 337 {
            return "北西"
        } else {
            return "北"
        }
    }
}
