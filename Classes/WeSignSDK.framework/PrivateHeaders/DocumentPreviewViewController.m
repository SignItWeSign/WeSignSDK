//
//  DocumentPreviewViewController.m
//  WeSignSDK
//
//  Created by apple on 15/9/7.
//  Copyright (c) 2015年 signit. All rights reserved.
//

#import "DocumentPreviewViewController.h"
#import "common.h"

@interface DocumentPreviewViewController ()
{
    NSData *data;
}
@property(strong, nonatomic) UIImageView *img;
@end

@implementation DocumentPreviewViewController

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (!self) {
        //TODO: init
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
    queue = dispatch_queue_create("com.signit.wesign.queue", NULL);
    
    ctx = fz_new_context(NULL, NULL, 25<<20);
    fz_register_document_handlers(ctx);
    screenScale = [[UIScreen mainScreen]scale];
#ifdef CRASHLYTICS_ENABLE
    NSLog(@"Starting Crashlytics");
    [Crashlytics startWithAPIKey:CRASHLYTICS_API_KEY];
#endif
    NSString *file = [[NSBundle mainBundle]pathForResource:@"b" ofType:@"pdf"];
    data = [NSData dataWithContentsOfFile:file];
    self.img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 70, 300, 300)];
    self.img.image = [self getFirstPageWithSize:CGSizeMake(300, 300)];
    [self.view addSubview:self.img];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)infomation
{
    NSLog(@"infomation");
}

- (UIImage*)getFirstPageWithSize:(CGSize)imageSize
{
    NSString* outpath = [NSString stringWithFormat:@"%@/Documents/cache.png", NSHomeDirectory()];
    UIImage *img;
    dispatch_sync(queue, ^{
    });
    //渲染第一页
    fz_stream* stream = fz_open_memory(ctx, (unsigned char*)data.bytes, (int)data.length);
    fz_document* doc = fz_open_document_with_stream(ctx, "application/pdf", stream);
    if (fz_needs_password(doc)) //需要密码
    {
        fz_close_document(doc);
        fz_close(stream);
        return nil;
    }
    if (fz_count_pages(doc) == 0) {
        fz_close_document(doc);
        fz_close(stream);
        return nil;
    }
    //load the page, page number starts from zero
    fz_page* page = fz_load_page(doc, 0);
    
    //calculate a transform, transform contains zooms and rotation
    fz_matrix transform;
    fz_rotate(&transform, 0);
    fz_pre_scale(&transform, 1.0f, 1.0f);
    
    //calculate page bounds
    fz_rect bounds;
    fz_bound_page(doc, page, &bounds);
    fz_transform_rect(&bounds, &transform);
    
    //create a blank pixmap to hold the result of rendering.
    fz_irect bbox;
    fz_round_rect(&bbox, &bounds);
    fz_pixmap* pix = fz_new_pixmap_with_bbox(ctx, fz_device_rgb(ctx), &bbox);
    
    fz_clear_pixmap_with_value(ctx, pix, 0xff);
    
    //create a draw device with pixmap as its target
    fz_device* dev = fz_new_draw_device(ctx, pix);
    fz_run_page(doc, page, dev, &transform, NULL);
    fz_free_device(dev);
    
    char* _outpath = malloc(strlen([outpath UTF8String]) + 1);
    strcpy(_outpath, [outpath UTF8String]);
    fz_write_png(ctx, pix, _outpath, 0);
    data = [NSData dataWithContentsOfFile:outpath];
    img = [UIImage imageWithData:data];
    //clean up
    free(_outpath);
    fz_drop_pixmap(ctx, pix);
    fz_free_page(doc, page);
    fz_close_document(doc);
    fz_close(stream);
    return img;
}


@end
