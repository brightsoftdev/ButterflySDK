HOW TO USE:

- Create new xcode project
- drag library XCode project into host project
- Navigate to Targets -> Build Phases -> Target Dependencies and add Library Project
- In same area, navigate to Link Binary with Libraries and add Library Project
- In Build Settings, find "Other Linker Flags" and add -ObjC AND -all_load
- In "Header Search Paths" add "$(TARGET_BUILD_DIR)/usr/local/lib/include" and "$(OBJROOT)/UninstalledProducts/include" WITH QUOTES
- Import library into new project source files, like:
	#import <ButterflySDK/ButterflySDK.h>
- add required frameworks (see frameworks.png)
- import "resources" folder into the main project directory - select copy option.
- In the App Delegate, instantiate a ButterflyManager object and configure it.  Then, make it a property on the AppDelegate:

    - @property (retain, nonatomic) ButterflyManager *butterflyMgr
    - Set butterflyMgr in appDidFinishLaunching method.


- Build


NOTES:
- Every ViewController in the SDK subclasses "ButterflyViewController" which has a property "ButterflyManager."  The ButterflyMgr property manages all Butterfly operations. Every time you instantiate an SDK View Controller, pass off the ButterflyMgr from the AppDelegate.

- whenever you instantiate an SDK View Controller, pass off the ButterflyMgr instance from the App Delegate to the VC

- Update definitions in Globals.h
