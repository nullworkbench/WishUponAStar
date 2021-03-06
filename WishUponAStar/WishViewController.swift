//
//  WishViewController.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/02/23.
//

import UIKit

class WishViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var wishTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wishTextField.delegate = self

        if let wish = UserDefaults.standard.string(forKey: "wish") {
            wishTextField.text = wish
        }
    }
    
    // Returnでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func doneButton() {
        // 禁止ワードが含まれていないか確認
        if checkRestrictionWord(wishTextField.text!) {
            let alert = UIAlertController(title: "不適切な単語が含まれています。", message: "他人へ悪影響を与える恐れのあるお願いはご遠慮ください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            UserDefaults.standard.set(wishTextField.text, forKey: "wish")
            self.dismiss(animated: true, completion: nil)
        }
        
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
