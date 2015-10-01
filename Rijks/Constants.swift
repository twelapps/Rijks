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
        
        static let sqLiteFileName            = "Rijks.sqlite"                                 // Used in CoreDataStackManager.swift
        static let directoryExtension        = "/Rijks-images"
        
        static let RijksWebsiteUrlString     = "http://www.rijksmuseum.nl/"
        static let hotMsgSourceUrlString     = "http://www.twelker.nl/rijks/hotmessage.php"
        
        static let ApiKey                    = "XgLYdYGM"
        static let BaseUrlSSL                = "https://www.rijksmuseum.nl/api/en/collection" // Only "collection" endpoint for now
        static let Favorite                  = "YES"
        static let Unfavorite                = "NO"
        static let safariImage               = "Safari.png"
        static let favArtistsImage           = "Favorites Artists.png"
        static let hotNewsImage              = "HotNews.png"
        static let directionsImage           = "Directions.png"
        static let settingsImage             = "Settings.png"
        static let favArtworksImage          = "Favorites Artworks.png"
        
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
        
        static let detailScrollImageVC       = "RijksArtworkDetailScrollVC"
        static let detailFixedImageVC        = "RijksArtworkDetailVC"
        static let hotMessagesVC             = "RijksWhatIsHotVC"
        static let settingsVC                = "RijksSettingsVC"
        static let artworksCollVC            = "RijksArtworksCollectionVC"
        static let favArtworksCollVC         = "RijksFavoriteArtworksCollectionVC"
        static let favArtistsVC              = "RijksFavoriteArtistsVC"
        static let artistPickerVC            = "RijksArtistPickerVC"
        static let RijksWebsiteVC            = "RijksWebsite"
        static let imageScrollableArch       = "imageScrollable"
        static let imageScrollableDefault    = true
        
        static let alertTitle                = "Oops!"
        static let alertMsg                  = "Shouldn't remove artist until all artworks are downloaded"
        static let alertActionOK             = "OK"
        static let alertActionNotOK          = "Still remove"
    }
    
}