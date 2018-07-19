//
//  Constants.swift
//  pixal-city
//
//  Created by Stephen Reyes on 7/19/18.
//  Copyright © 2018 Stephen Reyes. All rights reserved.
//

import Foundation

let apiKey = "186524fc70e11f6e130d98349ef51d79"

func flickrURL(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1.0&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    
    
}





