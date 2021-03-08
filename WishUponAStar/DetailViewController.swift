//
//  DetailViewController.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/03/09.
//

import UIKit

class DetailViewController: UIViewController {
    
    var direction: CGFloat!
    var wish: String!
    var uid: String!
    
    @IBOutlet var wishLabel: UILabel!
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var uidLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        wishLabel.text = wish
        directionLabel.text = String(format: "%.01f", Float(direction)) + " " + judgeDirection(Float(direction))
        uidLabel.text = uid
    }
    
    
    @IBAction func report() {
        
    }
    
    @IBAction func blockUser() {
        
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
