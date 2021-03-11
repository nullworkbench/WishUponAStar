//
//  EULAViewController.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/03/09.
//

import UIKit

class EULAViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func agree() {
        let alert = UIAlertController(title: "同意しますか？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "同意しない", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "同意する", style: .default, handler: { action in
            self.performSegue(withIdentifier: "toSetUpWishView", sender: nil)
        }))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func disagree() {
        let alert = UIAlertController(title: "アプリを利用できません。", message: "利用規約にご同意いただけない場合、アプリは利用できません。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
