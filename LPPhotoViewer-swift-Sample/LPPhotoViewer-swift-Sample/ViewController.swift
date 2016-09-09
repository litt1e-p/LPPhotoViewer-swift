//
//  ViewController.swift
//  LPPhotoViewer-swift-Sample
//
//  Created by litt1e-p on 16/5/16.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .redColor()
    }
    
    let imgArrs: [String] = [
                            "https://drscdn.500px.org/photo/146512755/q=80_m=2000_k=1/62c584ed280fb11bbdb7d1c5451b6676",
                            "https://drscdn.500px.org/photo/85567631/q%3D85_w%3D560_s%3D1/86ec6bbfc690723af5f2e40d8c832956",
                            "https://drscdn.500px.org/photo/146441995/q=80_m=2000/0a6e687c0750ea05abf709bbd8c3d7f8"
                            ]

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        showPhotoViewer()
    }
    
    private func showPhotoViewer(fromIndex: Int = 0) {
        let pv           = LPPhotoViewer()
        pv.currentIndex  = fromIndex
        pv.imgArr        = imgArrs
        pv.indicatorType = .PageControl
        presentViewController(pv, animated: true, completion: nil)
    }
}
