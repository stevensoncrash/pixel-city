//
//  DroppablePin.swift
//  pixal-city
//
//  Created by Stephen Reyes on 6/29/18.
//  Copyright © 2018 Stephen Reyes. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class DroppablePin: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
    
    
    
    
    
}
