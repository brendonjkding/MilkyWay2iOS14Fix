#import <notify.h>
#import <substrate.h>

@interface SBAppLayout : NSObject
@end

%hook SBAppLayout
%new 
-(id)rolesToLayoutItemsMap{
    return MSHookIvar<id>(self,"_rolesToLayoutItemsMap");
}
%end //SBApplayout

%ctor{
	NSLog(@"ctor: MilkyWay2iOS14Fix");


}
