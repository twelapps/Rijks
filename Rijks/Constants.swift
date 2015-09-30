//
//  Constants.swift
//  Rijks
//
//  Created by Twelker on Sep/21/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import Foundation
import UIKit

extension Rijks {
    
    struct Constants {
        
        static let RijksWebsiteUrlString     = "http://www.rijksmuseum.nl/"
        static let hotMsgSourceUrlString     = "http://www.twelker.nl/rijks/hotmessage.php"
        
        static let ApiKey                    = "XgLYdYGM"
        static let BaseUrlSSL                = "https://www.rijksmuseum.nl/api/en/collection" // Only "collection" endpoint for now
        static let Favorite                  = "YES"
        static let Unfavorite                = "NO"
        
        static let msgImageNotDownloaded     = "Image could not be downloaded. No/bad Internet?"
        static let msgNoWebsite              = "Rijksmuseum website could not be opened. No/bad Internet?"
        static let msgNoArtistsFound         = "No artists found."
        static let msgNoHotMessage           = "No hot message found. No/bad Internet?"
        static let maxNrFavs                 = 20
        static let msgMaxNrFavsReached       = "Maximum number of favorite artworks (" + String(maxNrFavs) + ") reached. Remove some."
        static let iPhone                    = "iPhone"
        static let iPad                      = "iPad"
        static let portrait                  = "portrait"
        static let landscape                 = "landscape"
        static let iPhonePortraitImagesRow   : CGFloat = 2
        static let iPhonePortraitImagesCol   : CGFloat = 3
        static let iPhoneLandscapeImagesRow  : CGFloat = 3
        static let iPhoneLandscapeImagesCol  : CGFloat = 2
        static let iPadPortraitImagesRow     : CGFloat = 3
        static let iPadPortraitImagesCol     : CGFloat = 4
        static let iPadLandscapeImagesRow    : CGFloat = 4
        static let iPadLandscapeImagesCol    : CGFloat = 3
        
    }
    
}