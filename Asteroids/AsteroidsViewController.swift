//
//  AsteroidsViewController.swift
//  Asteroids
//
//  Created by Terrill Thorne on 5/31/17.
//  Copyright © 2017 Terrill Thorne. All rights reserved.
//

import UIKit

// stopped video at 43.43
class AsteroidsViewController: UIViewController {
    
    @IBAction func burn(_ sender: UILongPressGestureRecognizer) {
           switch sender.state {
        
        case .began,.changed:
            ship.direction = (sender.location(in: view) - ship.center).angle
            burn()
      
        case .ended:
           endBurn()
            
        default: break
            
        }
    }
    
    private var asteroidField: AsteroidFieldView! // this field will always be set
    private var asteroidBehavior = AsteroidBehavior() // creates asteroid behavior
    private var ship: SpaceshipView!
    
    private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.asteroidField) // used lazy because the asteroidField will not be initiliazed until its been asked
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated) // all bounds are set in viewDidAppear
       
        initializeIfNeeded()
        animator.addBehavior(asteroidBehavior) // starts animating the behavior of the asteroid
        asteroidBehavior.pushAllAsteroids()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        animator.removeBehavior(asteroidBehavior) // stops animating the behavior
    }
    
    private func initializeIfNeeded() {
        // asteroidField inside the whole view
        if asteroidField == nil {

            asteroidField = AsteroidFieldView(frame: CGRect(origin: view.bounds.origin, size: view.bounds.size * Constants.asteroidFieldMagnitude))

            asteroidField.addAsteroids(count: Constants.initialAsteroidCount) // # of asteroids added to the screen, converts the ships bounds to the asteroids coordinate system. Exlusion zone doesn't let asteroid spawn where ship is
            asteroidField.asteroidBehavior = asteroidBehavior // asteroid behavior added to the actual asteroid

            let shipSize = view.bounds.size.minEdge * Constants.shipSizeToMinBoundsEdgeRatio
            ship = SpaceshipView(frame: CGRect(sqareCenteredAt: asteroidField.center, size: shipSize)) // ship is going to be a square that is centered in the asteroid field 
            
            view.addSubview(asteroidField)
            view.addSubview(ship)

            repositionShip()
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        asteroidField?.center = view.bounds.mid // places asteroid back in the middle
        repositionShip()
    }
    
    
  private func burn() {
        ship.enginesAreFiring = true // image with flames will show
        asteroidBehavior.acceleration.angle = ship.direction - CGFloat.pi // turns the ship
        asteroidBehavior.acceleration.magnitude = Constants.burnAcceleration
    }
    
  private func endBurn() {
        ship.enginesAreFiring = false
        asteroidBehavior.acceleration.magnitude = 0 // stops accelerating 
        
    }
    
    private func repositionShip() {
        
        if asteroidField != nil {
        ship.center = asteroidField.center
        asteroidBehavior.setBoundary(ship.shieldBoundary(in: asteroidField), named: Constants.shipBoundaryName) {
        [weak self] in
              
        if let ship = self?.ship {
        if !ship.shieldIsActive { // makes the ship survive longer
        ship.shieldIsActive = true
        ship.shieldLevel -= Constants.Shield.activationCost // shield depletes everytime its turned on
            
        Timer.scheduledTimer(withTimeInterval: Constants.Shield.duration, repeats: false)  { timer in
        ship.shieldIsActive = false  // turns the shield back off
        if ship.shieldLevel == 0 { // ship has been destroyed
        ship.shieldLevel = 100 // resets the shield level of the ship
            }
                        }
                   }
                }
            }
        }
    }
    
    private struct Constants {
        static let initialAsteroidCount = 20
        static let shipBoundaryName = "ship"
        static let shipSizeToMinBoundsEdgeRatio: CGFloat = 1/5
        static let asteroidFieldMagnitude: CGFloat = 10
        static let normalizedDistanceOfShipFromEdge: CGFloat = 0.2
        static let burnAcceleration: CGFloat = 0.07
        
        struct Shield {
            static let duration: TimeInterval = 1.0 // how long shield stays up
            static let updateInterval: TimeInterval = 0.2 // how often to update shield level
            static let regenerationRate: Double = 5 // per second
            static let activationCost: Double = 15 // per activation
            
            static var regenerationPerUpdate: Double {
                return Constants.Shield.regenerationRate * Constants.Shield.updateInterval }
            
            static var activationCostPerUpdate: Double {
                return Constants.Shield.activationCost / (Constants.Shield.duration/Constants.Shield.updateInterval)}
            
        }
        
        static let defaultShipDirection: [UIInterfaceOrientation: CGFloat] = [
            .portrait : CGFloat.up ,
            .portraitUpsideDown: CGFloat.down,
            .landscapeLeft : CGFloat.right,
            .landscapeRight : CGFloat.left
        ]
        
        static let normalizedAsteroidFieldCenter: [UIInterfaceOrientation:CGPoint] = [
            .portrait : CGPoint(x: 0.5, y: 1.0-Constants.normalizedDistanceOfShipFromEdge),
            .landscapeLeft : CGPoint(x: Constants.normalizedDistanceOfShipFromEdge, y:0.5),
            .landscapeRight : CGPoint(x: Constants.normalizedDistanceOfShipFromEdge, y: 0.5),
            .unknown : CGPoint(x: 0.5, y: 0.5)
        ]
    }
    
    
}

