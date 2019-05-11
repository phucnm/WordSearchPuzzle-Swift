//
//  MainViewController.swift
//  WordSearch
//
//  Created by TonyNguyen on 5/10/19.
//  Copyright © 2019 Phuc Nguyen. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.layer.cornerRadius = playButton.frame.height / 2
        playButton.layer.masksToBounds = true
    }

    @IBAction func play(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameVC") as! GameViewController
        present(vc, animated: true, completion: nil)
    }
}
