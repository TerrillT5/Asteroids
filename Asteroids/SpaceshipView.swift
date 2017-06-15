//
//  SpaceshipView.swift
//  Asteroids
//
//  Created by Terrill Thorne on 5/31/17.
//  Copyright © 2017 Terrill Thorne. All rights reserved.
//

import UIKit

// stopped  14th vid at 13.43
class SpaceshipView: UIView {
    
    // https://github.com/duliodenis/cs193p-Winter-2017/blob/master/democode/Lecture-14-Demo-Code_Asteroids.pdf
    
    var enginesAreFiring = false { didSet { if !exploding { resetShipImage() } } } // turns on the fire of the ship
    var direction: CGFloat = 0 { didSet { updateDirection() } } // direction the ship is pointing
    var shieldLevel: Double = 100 { didSet { shieldLevel = min(max(shieldLevel, 0), 100); shieldLevelChanged() } } // the damage of the ship. starts at 100 then drops until ship explodes| 100 is a full shield
    var shieldIsActive = false { didSet { setNeedsDisplay() } } // makes the shield glow 
    
    func shieldBoundary(in view: UIView) -> UIBezierPath { return getShieldPath(in: view) } // describes the arc of the shield for the ship
    
    private struct Constants {
        
        static let explosionDuration: TimeInterval = 1.5
        static let explosionToFadeRatio: Double = 1/4
        static let shieldActiveLinewidthRatio: CGFloat = 3
        static let shipImage = #imageLiteral(resourceName: "ship")
        static let shipWithEnginesFiringImage = #imageLiteral(resourceName: "shipFiring")
        static let explosionImage = UIImage.animatedImageNamed("explosion", duration: 1.5)
    
}
    private var shieldLineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() }  }
    private let imageView = UIImageView(image: Constants.shipImage)

    override init(frame:CGRect) {
        super.init(frame: frame)
        resetShipImage()
}

    override func layoutSubviews() {
        super.layoutSubviews()
     
        updateImageViewFrame()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        resetShipImage()
}
    
    override func draw(_ rect: CGRect) {
        
        if shieldLevel > 0 && shieldLevel < 100 && !exploding {
            
            UIColor.green.setStroke()
            getShieldPath().stroke()
            shieldColor.setStroke()
            getShieldPath(level:  shieldLevel).stroke()
        }
    }
    
    private func resetShipImage() {
        
        imageView.isHidden = ( shieldLevel == 0)
        if imageView.superview == nil {
            isOpaque = false
            addSubview(imageView)
        }
        imageView.image = enginesAreFiring ? Constants.shipWithEnginesFiringImage : Constants.shipImage
        updateImageViewFrame()
        updateDirection()
        imageView.alpha = 1
}
    
    private func updateImageViewFrame() {
        
        if !exploding && imageView.transform == CGAffineTransform.identity {
            imageView.frame = bounds
            
    }
}
    
    private func updateDirection() {
        if !exploding {
            imageView.transform = CGAffineTransform.identity.rotated(by: direction)
        }
    }
    

    private func shieldLevelChanged() {
        if !exploding {
            if shieldLevel == 0 && !imageView.isHidden {
                explode()
            } else {
                imageView.isHidden = (shieldLevel == 0)
                setNeedsDisplay()
            }
        }
    }

    private var shieldColor: UIColor {
        let red: CGFloat = shieldLevel < 50 ? 1 : 0
        let green: CGFloat = shieldLevel > 25 ? 1 : 0
        return UIColor(red: red, green: green, blue: 0, alpha: 1)
        
    }

    private func getShieldPath(level: Double = 100, in view: UIView? = nil) -> UIBezierPath {
        var middle = CGPoint(x: bounds.midX, y: bounds.midY)
        if view != nil { middle = self.convert(middle, to: view) }
        let radius = min(bounds.size.width, bounds.size.height) / 2 - shieldLineWidth
        let startAngle = -CGFloat.pi/2
        let endAngle = -CGFloat.pi/2 + CGFloat(level)/100 * CGFloat.pi*2
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
        path.lineWidth = shieldLineWidth * (shieldIsActive ? Constants.shieldActiveLinewidthRatio : 1)
        return path
    }
        
   private var exploding: Bool {
        return imageView.image == Constants.explosionImage
    }
    
     func explode() {
        
        imageView.image = Constants.explosionImage
        imageView.transform = CGAffineTransform.identity
        imageView.startAnimating()
        setNeedsDisplay()
        
        let smallerFrame = imageView.frame.insetBy(
            dx: imageView.bounds.size.width * 0.30,
            dy: imageView.bounds.size.height * 0.30)
        
        _ = imageView.frame.insetBy(            // let bigger frame 
            dx: -imageView.bounds.size.width * 0.15,
            dy: -imageView.bounds.size.height * 0.15)

        imageView.frame = smallerFrame
        let explodeTime = Constants.explosionDuration * Constants.explosionToFadeRatio
        UIView.animate(withDuration: Constants.explosionDuration - explodeTime, animations: {
            self.imageView.alpha = 0
            self.imageView.frame = smallerFrame}, completion: { finished in
            self.resetShipImage()
        
        })
    
    }
    
}

