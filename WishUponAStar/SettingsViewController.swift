//
//  SettingsViewController.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/03/09.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // AppDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ナビゲーションバーの色を変更（動作不良）
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 37, green: 41, blue: 73, alpha: 1)
        
        table.delegate = self
        table.dataSource = self
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = "ブロックしたユーザー"
        cell?.textLabel?.textColor = UIColor.white
        
        return cell!
    }

}
