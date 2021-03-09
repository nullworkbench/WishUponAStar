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

        if let array = UserDefaults.standard.array(forKey: "blockedUidsArray") {
            blockedUidsArray = array as! [String]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUidsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = blockedUidsArray[indexPath.row]
        cell?.textLabel?.textColor = UIColor.white
        
        return cell!
    }
    


}
