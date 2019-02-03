
#import "Snackbar.h"
#import "iSnackBar.h"

@interface Snackbar() <iSnackBarSelectionDelegate>{
    RCTResponseSenderBlock actionCallback;
}

@end

@implementation Snackbar
    
    
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(show:(NSDictionary *)options withCallback:(RCTResponseSenderBlock)callback) {
    if (callback) {
        actionCallback = callback;
    }
    NSNumber *duration = (options[@"duration"])? options[@"duration"] : 0;
    NSDictionary *actionDictionary = options[@"action"];
    UIFont *font;
    if (options[@"fontFamily"]) {
        if (options[@"fontSize"]) {
            NSNumber *fontSize = options[@"fontSize"];
            font = [UIFont fontWithName:options[@"fontFamily"] size:fontSize.floatValue];
        } else {
            font = [UIFont fontWithName:options[@"fontFamily"] size:13.0];
        }
    }
    UIColor *backgroundColor = (options[@"backgroundColor"])? [RCTConvert UIColor:options[@"backgroundColor"]] : nil;
    UIColor *textColor = (options[@"color"])? [RCTConvert UIColor:options[@"color"]] : nil;
    UIColor *actionTitleColor = (actionDictionary[@"color"])? [RCTConvert UIColor:actionDictionary[@"color"]] : nil;


    [iSnackBar snackBarWithMessage:options[@"title"] font:font backgroundColor:backgroundColor textColor:textColor actionTitle:actionDictionary[@"title"] actionTitleColor:actionTitleColor delegate:self duration:duration.floatValue];
}

RCT_EXPORT_METHOD(dismiss) {
    [iSnackBar dismissSnackBar];
}
    
-(NSDictionary *)constantsToExport {
    return [NSDictionary dictionaryWithObjectsAndKeys:@(-2),@"LENGTH_INDEFINITE",@(0),@"LENGTH_LONG",@(-1),@"LENGTH_SHORT",@"rtl",@"DIRECTION_RTL",@"ltr",@"DIRECTION_LTR",@(0),@"BAR_POSITION_TOP",@(1),@"BAR_POSITION_BOTTOM", nil];
}

-(void)didSelectSnackBarAction {
    if (actionCallback) {
        actionCallback(@[]);
    }
}

@end

