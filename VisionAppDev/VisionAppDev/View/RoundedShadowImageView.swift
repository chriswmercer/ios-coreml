//
//  RoundedShadowImageView.swift
//  VisionAppDev
//
//  Created by Chris Mercer on 25/04/2020.
//  Copyright © 2020 Chris Mercer. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedShadowImageView: UIImageView {

    override func awakeFromNib() {
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    private func setupView() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = 15
    }
}
