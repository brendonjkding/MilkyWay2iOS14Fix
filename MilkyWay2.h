@interface AXFlexHelper : NSObject
+ (FBScene*)getFBScene:(NSString*)identifier;
@end

@interface AXWindowView : UIView
@property(retain, nonatomic) UIView *contentView; // @synthesize contentView=_contentView;
@end

@interface AXPassthroughWindow : UIWindow
- (instancetype)initWithNoRotation;
@end