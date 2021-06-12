#import <FrontBoard/FBSMutableSceneSettings.h>
#import <FrontBoard/FBScene.h>

@interface AXFlexHelper : NSObject
+ (FBScene*)getFBScene:(NSString*)identifier;
+ (void)wakeUpScene:(id)identifier;
@end

@interface AXWindowView : UIView
@property(retain, nonatomic) UIView *contentView; // @synthesize contentView=_contentView;
- (instancetype)initWithContentView:(id)arg1 identifier:(id)arg2 scene:(id)arg3;
@end

@interface AXPassthroughWindow : UIWindow
+ (void)notifyUpdateLayers;
+ (AXPassthroughWindow*)sharedInstance;
- (instancetype)initWithNoRotation;
@end

@interface AXBackgrounderManager : NSObject
+ (void)setForegroundSceneID:(NSString*)sceneIdentifier WithBool:(BOOL)arg2;
@end