//
//  PopVC.swift
//  pixal-city
//
//  Created by Stephen Reyes on 7/19/18.
//  Copyright © 2018 Stephen Reyes. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    
    var pastImage: UIImage!
    
    func initData(forImage image: UIImage) {
        self.pastImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = pastImage
        addDoubleTap()
    
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped(){
        dismiss(animated: true, completion: nil)
        }
    }

