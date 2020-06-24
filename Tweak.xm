/**
 * @author Hao Nguyen
 */

#import "Tweak.h"

BOOL killAllBySwipeDownAppSwitcher;
BOOL hapticFeedbackAfterKill;
int uiEffect;
int swipeDownOffset;

static void reloadPrefs() {
  NSDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH] ?: [@{} mutableCopy];

  killAllBySwipeDownAppSwitcher = [[settings objectForKey:@"killAllBySwipeDownAppSwitcher"] ?: @(YES) boolValue];
  hapticFeedbackAfterKill = [[settings objectForKey:@"hapticFeedbackAfterKill"] ?: @(YES) boolValue];
  uiEffect = [[settings objectForKey:@"uiEffect"] intValue] ?: 0;
  swipeDownOffset = [[settings objectForKey:@"swipeDownOffset"] intValue] ?: 100;
}

static void makeBlurEffect(UIView *view, double duration) {
  UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
  UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
  blurEffectView.frame = view.bounds;
  blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  blurEffectView.alpha = 0.7;
  [view addSubview:blurEffectView];
  [UIView animateWithDuration:duration animations:^{
    blurEffectView.alpha = 1.0;
  } completion: ^(BOOL finished){
    [blurEffectView removeFromSuperview];
  }];
}

static void makeFadeEffect(UIView *view, double duration) {
  view.alpha = 0.5;
  [UIView animateWithDuration:duration animations:^{
    view.alpha = 0.0;
  } completion: ^(BOOL finished){
    view.alpha = 1.0;
  }];
}

%group KillAllBySwipeDownAppSwitcher
  %hook SBFluidSwitcherItemContainer
    - (void)scrollViewWillEndDragging:(UIScrollView *)arg1 withVelocity:(CGPoint)arg2 targetContentOffset:(CGPoint *)arg3 {
      %orig;
      if (arg1.contentOffset.y <= -swipeDownOffset) {
        SBMainSwitcherViewController *mainVC = [%c(SBMainSwitcherViewController) sharedInstance];

        NSArray *appLayouts = nil;
        if (@available(iOS 13, *)) {
          appLayouts = [mainVC recentAppLayouts];
        } else {
          appLayouts = [mainVC appLayouts];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          for (id appLayout in appLayouts) {
            [mainVC switcherContentController:mainVC.contentViewController deletedAppLayout:appLayout forReason:1];
          }
        });

        if (uiEffect == 0) {
          makeFadeEffect(mainVC.view, 0.6);
        } else if (uiEffect == 1) {
          makeBlurEffect(mainVC.view, 0.6);
        }

        if (hapticFeedbackAfterKill) {
          AudioServicesPlaySystemSound(1519);
        }
      }
    }
  %end
%end

/*
%hook SBFluidSwitcherViewController
  - (void)scrollViewKillingProgressUpdated:(double)arg1 ofContainer:(id)arg2 {
    if (arg1 <= -0.2) {
      [self.visibleItemContainers enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if (@available(iOS 13, *)) {
          [self killContainer:value forReason:1];
        } else {
          [self killAppLayoutOfContainer:value withVelocity:0 forReason:1];
        }
      }];
      return;
    }
    %orig;
  }
%end
*/


%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) reloadPrefs, CFSTR(PREF_CHANGED_NOTIF), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  reloadPrefs();

  if (killAllBySwipeDownAppSwitcher) {
    %init(KillAllBySwipeDownAppSwitcher);
  }
}

