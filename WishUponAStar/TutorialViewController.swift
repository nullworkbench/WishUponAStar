//
//  TutorialViewController.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/02/25.
//

import UIKit

class TutorialViewController: UIViewController {
    
    @IBOutlet var appNameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideContents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Animation
        self.welcomeAnimation()
    }
    
    func hideContents() {
        appNameLabel.alpha = 0
        descriptionLabel.alpha = 0
        nextButton.alpha = 0
    }
    
    func welcomeAnimation() {
        // appNameLabel
        appNameLabel.center.y += 180
        UILabel.animate(withDuration: 1,
                        delay: 0,
                        options: .curveEaseIn,
                        animations: {
                            self.appNameLabel.alpha = 1
                            self.appNameLabel.center.y -= 50
                        }, completion: nil)
        UILabel.animate(withDuration: 1,
                        delay: 1.5,
                        options: .curveEaseOut,
                        animations: {
                            self.appNameLabel.center.y -= 130
                        }, completion: nil)
        
        // descriptionLabel
        UILabel.animate(withDuration: 1,
                        delay: 2.5,
                        options: .curveEaseIn,
                        animations: {
                            self.descriptionLabel.alpha = 1
                        }, completion: nil)
        
        // nextButton
        UIButton.animate(withDuration: 1,
                         delay: 5,
                         options: .curveEaseIn,
                         animations: {
                            self.nextButton.alpha = 1
                         }, completion: nil)
    }
    
    @IBAction func nextButtonTapped() {
        // 次回以降は初回起動でないことを保存
        UserDefaults.standard.set(true, forKey: "isNotFirstLaunch")
        
        let viewController = self.presentingViewController?.presentingViewController?.presentingViewController as! ViewController // 3つ前のViewController
        viewController.isTutorialGoing = true // 値渡し（チュートリアルを続行）
        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil) // 3つ前の画面にもどる
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
