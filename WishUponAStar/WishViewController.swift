//
//  WishViewController.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/02/23.
//

import UIKit

class WishViewController: UIViewController {
    
    @IBOutlet var wishTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let wish = UserDefaults.standard.string(forKey: "wish") {
            wishTextField.text = wish
        }
    }
    
    @IBAction func doneButton() {
        UserDefaults.standard.set(wishTextField.text, forKey: "wish")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton() {
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
