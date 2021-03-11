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

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var postsArray: [Post] = []
    
    var selectedPost: Post?
    
    // Firestore
    var db: Firestore!
    
    @IBOutlet var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        table.dataSource = self
        table.delegate = self
        
        //Firestore
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        postsArray = []
        // 最新50件を取得
        db.collection("posts").order(by: "createdAt", descending: true).limit(to: 50).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                // すべての投稿をpostsArrayへ格納
                for document in querySnapshot!.documents {
                    let data = document.data()
                    // 投稿がブロック済のユーザーであればskip
                    if self.isBlockedUser(uid: data["uid"] as! String) {
                        continue
                    } else {
                        self.postsArray.append(Post(docId: document.documentID,
                                                    wish: data["wish"] as! String,
                                                    direction: data["direction"] as! Float,
                                                    date: (data["createdAt"] as! Timestamp).dateValue(),
                                                    uid: data["uid"] as! String
                        ))
                    }
                }
                
                // FirestoreのクエリがtableViewの描画開始に間に合わないため再読み込み
                self.table.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailView" {
            let detailView = segue.destination as! DetailViewController
            detailView.docId = selectedPost?.docId
            detailView.wish = selectedPost?.wish
            detailView.direction = selectedPost?.direction
            detailView.createdAt = selectedPost?.date
            detailView.uid = selectedPost?.uid
        }
    }
    
    // 前画面のViewWillAppear, ViewDidAppearが実行されるように
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
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
        directionLabel.text = judgeDirection(postsArray[indexPath.row].direction)
        dateLabel.text = stringFromDate(date: postsArray[indexPath.row].date, format: "yyyy/MM/dd HH:mm:ss")
        
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPost = postsArray[indexPath.row]
        performSegue(withIdentifier: "toDetailView", sender: nil)
    }
    
    
    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    

}

class Post {
    var docId: String!
    var wish: String!
    var direction: Float!
    var date: Date!
    var uid: String!
    
    init(docId: String, wish: String, direction: Float, date: Date, uid: String) {
        self.docId = docId
        self.wish = wish
        self.direction = direction
        self.date = date
        self.uid = uid
    }
}
