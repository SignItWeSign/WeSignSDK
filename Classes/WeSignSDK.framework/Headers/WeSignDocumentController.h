#import <UIKit/UIKit.h>

#undef ABS
#undef MIN
#undef MAX

enum {
    BARMODE_MAIN,
    BARMODE_SIGNATURE,
    BARMODE_KEYDOWNMENU
};

@class Document;
@class UIPageIndicator;
@class UIPageIndicatorDataSource;
@class UIPageIndicatorDataModel;
@interface WeSignDocumentController : UIViewController
- (instancetype)initWithFile:(NSURL *)url;
- (instancetype)initWithData:(NSData *)fileData;
- (void)gotoPage:(int)number animated:(BOOL)animated;
- (void)showNavigationBar;
- (void)hideNavigationBar;
@end
