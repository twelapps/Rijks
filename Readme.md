
### Rijks specs and some remarks

App for viewing paintings owned by the world-famous Rijksmuseum in Amsterdam, Netherlands.
Paintings from painters like Rembrandt can be viewed there. Perhaps the “Nightwatch” is the most famous one.

Main view: 
- status bar: white letters, black background (this is the same for all view in this app)
- navigation:
    o  leftmost button: Rijksmuseum website (via WebView)
    o  right of leftmost button: favourite artists (painters only in this app)
    o  third (middle) button is not visible initially and if there are no favourite artworks at all, only after “favourizing” at least one artwork
    o  button "hot news", left of rightmost button: a hot message is picked up from my own server at www.twelker.nl
    o  rightmost button: directions to the Rijksmuseum. Selecting this option navigates to a map displaying (when feasible) the route between your current location and the museum. Using iOS 9 feature to return to the original app in the left hand upper corner: “< Return to Rijks” option. 
    o  top right button: navigates to set-up menu
- Round robin of 
    o  5 pre-set images if no favourite artworks are defined
    o  image of the Rijksmuseum building and all favourite artworks if at least one artwork has been "favourized" 
Note: the quality of the pre-set images is not so high. However the quality of the images retrieved from the Rijksmuseum database is very good with high resolution. For maximum experience the app should therefore be installed on an iPad.

Favourite artists table view:
- Empty initially, select “+” to search for artists and select one or more
- Selecting an artist name row navigates to a collection view where artworks associated with the selected artist are displayed.
- Through selecting “Edit” a favourite artist and all associated artworks can be removed from the app.
- Selecting “<“ navigates back to the main view.

Artworks collection view
- After selecting an artist in the Favourite artists table view, all artworks associated with that artist are displayed in this collection view
- Initially there is a blue coloured heart in the right hand corner of each artwork meaning “artwork not my favourite"
Selecting it will “favourize" the artwork (red heart). Selecting a red heart will “unfavourize" the artwork again. This feature makes use of the layer property of the cell. The selections are kept in Core Data.
Note: a maximum of 20 favorite artworks is supported otherwise there is an increased risk of running into memory issues due to the high resolution of the artworks. 
- Selecting “<“ navigates back to the Favourite artists view.

Favorite artworks collection view
- After favourizing an artwork, and navigating back to the main menu, the button for selecting the “favourite artworks view” is now visible. And the round robin will now display the Rijksmuseum building and the favourized artwork(s).
- Selecting “Favourite artworks” displays the “Favourite artworks” view (without hearts this time since we know all displayed here are favourite)
- Selecting “<“ navigates back to the main view. 

Detailed artwork view
- Selecting any artwork (either in the “artworks collection view” or in the “Favourite artworks collection view") navigates to the detailed artwork view, showing a larger image of the selected artwork. Depending on the option set in the set-up menu, the image is scrollable or just fixed.
- Selecting “<“ navigates back to the appropriate collection view. 

Set-up menu
- Switch to define whether the image in the "Detailed artwork view" is scrollable or just fixed. Default is scrollable. The parameter is stored in UserDefaults.

All artists, artworks and favourite settings are persistent in Core Data. If the images were not retrieved previously, FetchResultsController is used to manage the display of artwork images in the Artworks collection view. Once retrieved from the web, these images are stored on the local “disk”. They will be removed if the user removes an artist from the app.

The Rijks app can be run both on iPhone and iPad. All device orientations are supported. Size of the images in the collection views changes upon change of orientation.

Deployment target is iOS 9.0 (under Swift 2.0 / Xcode 7.0).
Quite some code had to be modified in order to remove all compiler warnings.

One error message is visible in the message window:

Rijks[3406] <Error>: CGContextSaveGState: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.

This is related to the following setting in info.plist to support the white color status bar:

View controller-based status bar appearance; Boolean; NO

Removing that setting removes the error message. This is an Apple bug. 
