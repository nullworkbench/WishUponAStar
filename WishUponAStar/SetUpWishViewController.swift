//
//  SetUpWishViewController.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/03/11.
//

import UIKit

class SetUpWishViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var wishTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        wishTextField.delegate = self
    }
    
    // Returnでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveWish() {
        let wish = wishTextField.text!
        
        // 禁止ワードチェック
        if checkRestrictionWord(wish) {
            let alert = UIAlertController(title: "不適切な単語が含まれています。", message: "他人へ悪影響を与える恐れのあるお願いはご遠慮ください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            UserDefaults.standard.set(wish, forKey: "wish")
            performSegue(withIdentifier: "toTutorialView", sender: nil)
        }
    }

}
