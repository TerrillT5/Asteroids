//
//  AsteroidFieldView.swift
//  Asteroids
//
//  Created by Terrill Thorne on 5/31/17.
//  Copyright © 2017 Terrill Thorne. All rights reserved.
//

import UIKit

class AsteroidFieldView: UIView {
    
    var asteroidBehavior: AsteroidBehavior? { // optional because asteroids could be sitting still. This makes the asteroid behavior apply to all asteroids
        didSet {
            // remove asteroids from any previous behavior & add them to new behavior
            for asteroid in asteroids {
                oldValue?.removeAsteroid(asteroid: asteroid)
                asteroidBehavior?.addAsteroid(asteroid)
            }
        }
    }
    
    private var asteroids: [AsteroidView] {
        
        return subviews.flatMap { $0 as? AsteroidView }   // flatmap makes an new array with all things in the first array but with a closure that skips the things that are nil. "$"= each subview in the array
    }
    
    var scale: CGFloat = 1.0 // size of average asteroid (compared to bounds.size)
    var minAsteroidSize: CGFloat = 2.5 // compared to average
    var maxAsteroidSize: CGFloat = 20.0
    
    func addAsteroids(count: Int, exclusionZone: CGRect = CGRect.zero) { // doesn't place an asteroid ontop of the ship when starting 
        assert(!bounds.isEmpty, "can't add asteroids to an empty field")
//        let averageAsteroidSize = bounds.size * scale
        for _ in 0..<count {
            
            let asteroid = AsteroidView()
//            let rand = CGFloat.random(in: minAsteroidSize..<maxAsteroidSize)
//            print(asteroid.frame.size, asteroid.frame.size.area, averageAsteroidSize, rand)
//            print((asteroid.frame.size.width / averageAsteroidSize.width) * rand)

//            asteroid.frame.size =
//                CGSize(width: (asteroid.frame.size.height / averageAsteroidSize.width) * 300, height: (asteroid.frame.size.height / averageAsteroidSize.width) * 300)
            repeat {
                
                asteroid.frame.origin = bounds.randomPoint // random asteroid placed inside a random point inside its bounds
            } while !exclusionZone.isEmpty && asteroid.frame.intersects(exclusionZone)
          
            addSubview(asteroid) // asteroidView added to the screen
            
            asteroidBehavior?.addAsteroid(asteroid) // final line in making the asteroids move around the screen 
//         print("asteroid size:", asteroid.frame.size)
        }
        
    }
}
