//
//  MapVC.swift
//  pixal-city
//
//  Created by Stephen Reyes on 6/28/18.
//  Copyright © 2018 Stephen Reyes. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    
    //outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    //actions
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
 
}

extension MapVC: MKMapViewDelegate{}
