#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoardServices/SBSApplicationShortcutItem.h>
#import "MilkyWay2.h"

@interface SBIconView : UIView
- (NSString*)applicationBundleIdentifier;
- (NSString*)applicationBundleIdentifierForShortcuts;
@end

static dispatch_source_t _timer;

@interface _UISceneLayerHostContainerView : UIView
- (id)initWithScene:(id)arg1;
@end

%hook SBIconView
// credits to https://github.com/opa334/Choicy/blob/master/ChoicySB/TweakSB.x#L171
- (NSArray *)applicationShortcutItems
{
    NSArray* orig = %orig;

    NSString* applicationID;
    if([self respondsToSelector:@selector(applicationBundleIdentifier)])
    {
        applicationID = [self applicationBundleIdentifier];
    }
    else if([self respondsToSelector:@selector(applicationBundleIdentifierForShortcuts)])
    {
        applicationID = [self applicationBundleIdentifierForShortcuts];
    }

    if(!applicationID)
    {
        return orig;
    }

    SBSApplicationShortcutItem* toggleSafeModeOnceItem = [[%c(SBSApplicationShortcutItem) alloc] init];
    toggleSafeModeOnceItem.localizedTitle = @"MilkyWay2";
    toggleSafeModeOnceItem.bundleIdentifierToLaunch = applicationID;
    toggleSafeModeOnceItem.type = @"com.brend0n.milkyway2-ios14fix";

    return [orig arrayByAddingObject:toggleSafeModeOnceItem];

}

+ (void)activateShortcut:(SBSApplicationShortcutItem*)item withBundleIdentifier:(NSString*)bundleID forIconView:(id)iconView
{
    if([[item type] isEqualToString:@"com.brend0n.milkyway2-ios14fix"])
    {
        [(SpringBoard*)[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:YES];

        if(_timer)  {
            dispatch_source_cancel(_timer);
            _timer = nil;
        }
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), (0.3/1.0) * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_timer, ^{
            FBScene *scene = [%c(AXFlexHelper) getFBScene:bundleID];
            NSString *sceneId = [scene identifier];
            if(!sceneId){
                return;
            }
            dispatch_source_cancel(_timer);
            _timer = nil;

            
            [%c(AXBackgrounderManager) setForegroundSceneID:sceneId WithBool:YES];
            [%c(AXFlexHelper) wakeUpScene:bundleID];
            _UISceneLayerHostContainerView *contentView = [[%c(_UISceneLayerHostContainerView) alloc] initWithScene:scene];
            AXWindowView *windowView = [[%c(AXWindowView) alloc] initWithContentView:contentView identifier:bundleID scene:scene];
            [[windowView titleLabel] setText:[[[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID] displayName]];

            [(AXPassthroughWindow*)[%c(AXPassthroughWindow) sharedInstance] addSubview:windowView];
            [%c(AXPassthroughWindow) notifyUpdateLayers];

            
        });
        dispatch_resume(_timer); 

    }
    else
    {
        %orig;    
    }
}

%end