//
//  BlockedUidsViewController.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/03/09.
//

import UIKit

class BlockedUidsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var blockedUidsArray = [String]()
    
    @IBOutlet var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem // 編集ボタンの指定
        
        // 下に引っ張って閉じる動作を禁止
        self.isModalInPresentation = true

        if let array = UserDefaults.standard.array(forKey: "blockedUidsArray") {
            blockedUidsArray = array as! [String]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if blockedUidsArray.count != 0 {
            return blockedUidsArray.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if blockedUidsArray.count != 0 {
            cell?.textLabel?.text = blockedUidsArray[indexPath.row]
        } else {
            cell?.textLabel?.text = "ブロック中のユーザーはいません。"
        }
        cell?.textLabel?.textColor = UIColor.white
        
        return cell!
    }
    
    // 編集モードの設定
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        table.isEditing = editing
    }
    
    // スワイプで削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        blockedUidsArray.remove(at: indexPath.row)
        UserDefaults.standard.set(blockedUidsArray, forKey: "blockedUidsArray")
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    


}
