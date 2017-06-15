//
//  AsteroidView.swift
//  Asteroids
//
//  Created by Terrill Thorne on 6/1/17.
//  Copyright © 2017 Terrill Thorne. All rights reserved.
//

import UIKit

class AsteroidView: UIImageView {

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    private func setup() {
        
        image = UIImage(named: "asteroid\((arc4random()%9)+1)") // picks one of the asteroids from 1-9
        frame.size = image?.size ?? CGSize.zero
        
 }
}
