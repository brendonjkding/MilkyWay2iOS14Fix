#import <dlfcn.h>
#import <substrate.h>
#import <FrontBoard/FBSMutableSceneSettings.h>
#import <FrontBoard/FBScene.h>
#import <FrontBoard/FBSceneManager.h>
#import <mach-o/dyld.h>

#import "MilkyWay2.h"
#import "_UISceneLayerHostContainerView.h"

static AXPassthroughWindow *keyboardWindow;

@interface FBScene ()
- (void)updateSettings:(id)arg1 withTransitionContext:(id)arg2 ;
@end

@interface FBSMutableSceneSettings ()
@property (assign,getter=isForeground,nonatomic) BOOL foreground;
@end

@interface SBAppLayout : NSObject
+(id)homeScreenAppLayout;
@end

@interface SBMainSwitcherViewController : UIViewController
+(id)sharedInstance;
-(BOOL)_dismissSwitcherNoninteractivelyToAppLayout:(SBAppLayout*)arg1 dismissFloatingSwitcher:(BOOL)arg2 animated:(BOOL)arg3 ;
@end

%group iOS14
%hook SBAppLayout
%new 
-(id)rolesToLayoutItemsMap{
    return MSHookIvar<id>(self,"_rolesToLayoutItemsMap");
}
%end //SBApplayout

%hook AXWindowView
-(void)updateLayers{
    %orig;
    for(UIView *hostView in [[self contentView] subviews]){
        if([hostView isKindOfClass:%c(_UIKeyboardLayerHostView)]){
            if(!keyboardWindow){
                keyboardWindow = [[%c(AXPassthroughWindow) alloc] initWithNoRotation];
                [keyboardWindow setBackgroundColor:[UIColor clearColor]];
                [keyboardWindow setWindowLevel:10000];
                [keyboardWindow makeKeyAndVisible];
            }
            for(UIView *subview in [keyboardWindow subviews]){
                [subview removeFromSuperview];
            }
            [keyboardWindow addSubview:hostView];
            [hostView setClipsToBounds:NO];
        }
    }
}
- (void)closeButtonAction:(id)arg1{
    if([[self contentView] respondsToSelector:@selector(invalidate)]){
        [(_UISceneLayerHostContainerView*)[self contentView] invalidate];
    }
    %orig;
}
%end //AXWindowView

%hook SBAppSwitcherPageView
-(void)AXlongPressAction:(UIGestureRecognizer*)gestureRecognizer{
    %orig;
    [[%c(SBMainSwitcherViewController) sharedInstance] _dismissSwitcherNoninteractivelyToAppLayout:[%c(SBAppLayout) homeScreenAppLayout] dismissFloatingSwitcher:YES animated:YES];
}
%end //SBAppSwitcherPageView
%end //iOS14


%group iOS15
%hook AXFlexHelper
+(FBScene*)getFBScene:(NSString*)identifier{
    FBSceneManager *manager = [%c(FBSceneManager) sharedInstance];
    id workspace = MSHookIvar<id>(manager, "_workspace");
    NSDictionary *_allScenesByID = MSHookIvar<NSDictionary*>(workspace, "_allScenesByID");
    for(NSString *key in [_allScenesByID allKeys]){
        if([key containsString:identifier]){
            return _allScenesByID[key];
        }
    }
    return nil;
}
+(void)wakeUpScene:(NSString*)identifier{
    FBScene *scene = [%c(AXFlexHelper) getFBScene:identifier];
    FBSMutableSceneSettings *mutableSetting = [[scene settings] mutableCopy];
    [mutableSetting setForeground:YES];
    [scene updateSettings:mutableSetting withTransitionContext:nil];
}
+(void)sleepScene:(NSString*)identifier{
    FBScene *scene = [%c(AXFlexHelper) getFBScene:identifier];
    FBSMutableSceneSettings *mutableSetting = [[scene settings] mutableCopy];
    [mutableSetting setForeground:NO];
    [scene updateSettings:mutableSetting withTransitionContext:nil];
}
%end //AXFlexHelper

%hook _UISceneLayerHostContainerView
%new
-(instancetype)initWithScene:(id)arg1{
    return [self initWithScene:arg1 debugDescription:@""];
}
%end //_UISceneLayerHostContainerView

%end //iOS 15

%ctor{
    NSLog(@"ctor: MilkyWay2iOS14Fix");

    #if TARGET_OS_SIMULATOR
    dlopen("/opt/simject/MilkyWay2.dylib", RTLD_NOW);
    #else
    dlopen("/Library/MobileSubstrate/DynamicLibraries/MilkyWay2.dylib", RTLD_NOW);
    #endif

    if(@available(iOS 15, *)){
        %init(iOS15);
    }
    if(@available(iOS 14, *)){
        %init(iOS14);
    }
}
