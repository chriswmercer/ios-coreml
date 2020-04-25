//
//  ViewController.swift
//  VisionAppDev
//
//  Created by Chris Mercer on 25/04/2020.
//  Copyright © 2020 Chris Mercer. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet weak var capturedItemNameLabel: UILabel!
    @IBOutlet weak var capturedItemConfidenceLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var flashToggleButton: UIView!
    @IBOutlet weak var capturedImageView: UIView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

