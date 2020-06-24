#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define PLIST_PATH "/var/mobile/Library/Preferences/com.haoict.killallappspref.plist"
#define PREF_CHANGED_NOTIF "com.haoict.killallappspref/PrefChanged"

@interface SBMainSwitcherViewController : UIViewController
+ (id)sharedInstance;
@property(readonly, nonatomic) id contentViewController;
- (id)appLayouts; // ios12
- (id)recentAppLayouts; // ios13
- (void)switcherContentController:(id)arg1 deletedAppLayout:(id)arg2 forReason:(long long)arg3;
@end