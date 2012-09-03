HOW TO USE:

1. Import required frameworks (see frameworks.png image).

2. Import follwing header files into App Delegate: #import <ButterflySDK/ButterflySDK.h>

3. In the App Delegate, instantiate a ButterflyManager object and configure it.  Then, make it a property on the AppDelegate:

    - @property (retain, nonatomic) ButterflyManager *butterflyMgr
    - Set butterflyMgr in appDidFinishLaunching method.



4. Every ViewController in the SDK subclasses "ButterflyViewController" which has a property "ButterflyManager."  The ButterflyMgr property manages all Butterfly operations. Every time you instantiate an SDK View Controller, pass off the ButterflyMgr from the AppDelegate.

5. whenever you instantiate an SDK View Controller, pass off the ButterflyMgr instance from the App Delegate to the VC

6. Update definitions in Globals.h


! ! IMPORTANT: SDK resources have to be copied separately in the main project directory - duplicate the "resources" folder and drag it into your main project directory.