//
//  AsteroidBehavior.swift
//  Asteroids
//
//  Created by Terrill Thorne on 6/1/17.
//  Copyright © 2017 Terrill Thorne. All rights reserved.
//

import UIKit

class AsteroidBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    private lazy var collider:  UICollisionBehavior = {
        
        let behavior = UICollisionBehavior()
        behavior.collisionMode = .boundaries // asteroid will only collide with boundaries
        //        behavior.translatesReferenceBoundsIntoBoundary = true // adds a rectangle boundary around the view
        behavior.collisionDelegate = self // finds out when a collision occurs with itself
        
        return behavior
    }()
    
    private var asteroids = [AsteroidView]()
    
    private lazy var physics: UIDynamicItemBehavior = { // UIDynamic behavior knows the speed
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 1          // when things collide, how much energy is lost. 1 means no energy is lost. ".5" means they slow down
        behavior.allowsRotation = true
        behavior.friction = 0           // objects will not slow down
        behavior.resistance = 0         // means somethings are getting pulled by gravity while others are not
        
        return behavior
        
    }()
    
    private var collisionHandlers = [String: (Void)-> Void]() // creating dictionary whos values will be the handlers, & keys will be the names
    
    var recaptureCount = 0
    private weak var recaptureTimer: Timer?
    
    private func startRecapturingWaywardAsteroids() {
        if recaptureTimer == nil {
            recaptureTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in // every half second, an asteroid is moved to the other side of the screen
                for asteroid in self?.asteroids ?? [] {
                    if let asteroidFieldBounds = asteroid.superview?.bounds, !asteroidFieldBounds.contains(asteroid.center)
                    {
                        asteroid.center.x = asteroid.center.x.truncatingRemainder(dividingBy: asteroidFieldBounds.width)
                        if asteroid.center.x < 0 { asteroid.center.x += asteroidFieldBounds.width }
                        
                        asteroid.center.y = asteroid.center.y.truncatingRemainder(dividingBy: asteroidFieldBounds.height)
                        if asteroid.center.y < 0 { asteroid.center.y += asteroidFieldBounds.height}
                        self?.dynamicAnimator?.updateItem(usingCurrentState: asteroid) // notifies animator that the asteroid has moved to a new position
                        self?.recaptureCount += 1 // keeps count of the recaptures
                    }
                }
            }
        }
    }
    
    private func stopRecapturingWaywardAsteroids() {
        recaptureTimer?.invalidate() // stops the timer
    }
    
    lazy var acceleration: UIGravityBehavior  = {   // adds gravity to the asteroids
        let behavior = UIGravityBehavior()
        behavior.magnitude = 0
        
        return behavior
    }()
    
    func setBoundary(_ path: UIBezierPath, named name: String, handler: ((Void) -> Void)?) { // handler added for collision with boundary, if so the handler will be called
        collider.removeBoundary(withIdentifier: name as NSString) // removes the old boundary if someone sets a new boundary
        collisionHandlers[name] = nil
        
        if path != nil {
            collider.addBoundary(withIdentifier: name as NSString, for: path) // boundary will only be added if a path is specified
            collisionHandlers[name] = handler // keeps track of handlers for each of the named boundaries
        }
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if let name = identifier as? String, let handler = collisionHandlers[name] {
            handler()
        }
    }
    
    func addAsteroid(_ asteroid: AsteroidView) {
        asteroids.append(asteroid) // asteroid added to the screen
        collider.addItem(asteroid)
        physics.addItem(asteroid) // adds physics to the asteroids
        acceleration.addItem(asteroid)
        startRecapturingWaywardAsteroids() // timer restarts
        
        if asteroids.isEmpty {
            stopRecapturingWaywardAsteroids() // timer stops
            
        }
    }
    
    func removeAsteroid(asteroid: AsteroidView) {
        
        if let index = asteroids.index(of: asteroid) {
            asteroids.remove(at: index) // asteroid removed from screen
        }
        collider.removeItem(asteroid)
        physics.removeItem(asteroid)
        acceleration.removeItem(asteroid)
        if asteroids.isEmpty {
            stopRecapturingWaywardAsteroids()
        }
    }
    
    func pushAllAsteroids(by magnitude: Range<CGFloat> = 0..<0.5) { // pushes asteroids in a random direction
        
        for asteroid in asteroids {
            let pusher = UIPushBehavior(items: [asteroid], mode: .instantaneous) // instantaneous is one push to get asteroids started. Continous is pushing it forever
            pusher.magnitude = CGFloat.random(in: magnitude) // force of the push
            pusher.angle = CGFloat.random(in: 0..<CGFloat.pi*2) // pushes at any random angle from 0 - 2pi
            addChildBehavior(pusher) // asteroid behavior will now initiate
        }
        
    }
    
    var speedLimit: CGFloat = 300.0
    
    override init() {
        super.init()
        
        addChildBehavior(collider)
        addChildBehavior(physics)
        addChildBehavior(acceleration)
        physics.action = { [weak self] in for
            asteroid in self?.asteroids  ?? [] {
                
                let velocity = self?.physics.linearVelocity(for: asteroid)
                let excessHorizontalVelocity = min(self!.speedLimit - (velocity?.x)!, 0)
                let excessVerticalVelocity = min(self!.speedLimit - (velocity?.y)!, 0)
                self?.physics.addLinearVelocity(CGPoint(x: excessHorizontalVelocity, y: excessVerticalVelocity), for: asteroid)
            }
        }
        
    }
    
    override func willMove(to dynamicAnimator: UIDynamicAnimator?) {
        super.willMove(to: dynamicAnimator)
        
        if dynamicAnimator == nil {
            stopRecapturingWaywardAsteroids() // timer ends
        } else if asteroids.isEmpty{
            self.startRecapturingWaywardAsteroids() // timer starts again
        }
    }

}

