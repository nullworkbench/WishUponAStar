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
    
    let settingListArray = ["ブロックしたユーザー", "お問い合わせ"]
    
    @IBOutlet var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ナビゲーションバーの色を変更（動作不良）
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 37, green: 41, blue: 73, alpha: 1)
        
        table.delegate = self
        table.dataSource = self
    }
    
    // 前画面のViewWillAppear, ViewDidAppearが実行されるように
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = settingListArray[indexPath.row]
        cell?.textLabel?.textColor = UIColor.white
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            // BlockedUidsViewへ遷移
            performSegue(withIdentifier: "toBlockedUidsView", sender: nil)
        case 1:
            let urlString = "https://docs.google.com/forms/d/e/1FAIpQLScmeFF9M47COHx8mVU2MCtDUSpU-tTDhQt93-R3FL-JxIxflQ/viewform?usp=sf_link"
            let formUrl = URL(string: urlString)
            UIApplication.shared.open(formUrl!) // Safariで開く
        default:
            return
        }
    }
    
    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }

}
