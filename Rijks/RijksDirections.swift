//
//  RijksDirections.swift
//  Rijks
//
//  Created by Twelker on Sep/23/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import UIKit
import AddressBook
import MapKit
import Contacts

extension RijksMainVC {
    
    func getDirection () {
    
        let geoCoder = CLGeocoder()
        
        // Destination address of which the map coordinates will be determined
        let addressString = "Rijksmuseum Amsterdam Netherlands"
        
        geoCoder.geocodeAddressString(addressString) { (placemarks, error) in
        
            if error != nil {
                self.throwMessage("Geocode failed with error: \(error!.localizedDescription)", color: UIColor.redColor())
            } else {
                if placemarks!.count > 0 {
                    let placemark = placemarks![0] as CLPlacemark
                    let location  = placemark.location
                    self.coords   = location!.coordinate
                    
                    self.showMap()
                }
            }
        }
    }

    func showMap() {
        
        // Descriptive text to be placed on the map
        let addressDict =
                [String(CNPostalAddressStreetKey)       : "Rijksmuseum",
                    String(CNPostalAddressCityKey)      : "Netherlands",
                    String(CNPostalAddressStateKey)     : "",
                    String(CNPostalAddressPostalCodeKey): "Amsterdam"]
        
        let place = MKPlacemark(coordinate: coords!, addressDictionary: addressDict)
        
        let mapItem = MKMapItem(placemark: place)
        
        let options = [MKLaunchOptionsDirectionsModeKey:
            MKLaunchOptionsDirectionsModeDriving]
        
        mapItem.openInMapsWithLaunchOptions(options)
    }
    
    func throwMessage (message: String, color: UIColor) {
        self.view.endEditing(true)  // Always end editing first
        messageField.backgroundColor = color
        messageField.alpha           = 1.0
        messageField.text            = message
    }
}
