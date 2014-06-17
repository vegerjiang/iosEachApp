//
//  VGViewController.m
//  testTo
//
//  Created by JiangHuifu on 14-6-17.
//  Copyright (c) 2014年 veger. All rights reserved.
//

#import "VGViewController.h"

@interface VGViewController ()
@property(nonatomic,retain) UIImageView* imageView;
@end

@implementation VGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40)];
    [self.view addSubview:_imageView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotification:) name:kLoadStr object:nil];
}
-(UIImage*)createImageFromString:(NSString*)string{
    NSDictionary* json =[NSJSONSerialization
                         JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] //1
                         
                         options:kNilOptions
                         error:nil];
    NSUInteger width = [[json objectForKey:@"width"] unsignedIntegerValue];
    NSUInteger height = [[json objectForKey:@"height"] unsignedIntegerValue];
    NSString* content = [json objectForKey:@"content"];
    
    Byte* stoneData = (Byte*)[content cStringUsingEncoding:NSUTF8StringEncoding];
    NSUInteger length = (4*(width-1)+4*(height-1)*width+3);
    Byte* data = (Byte*)malloc(sizeof(Byte)*length);
    Byte baseByte = (Byte)'a';
    for (NSUInteger i = 0; i<length; i++) {
        data[i] = ((stoneData[i*2+1] - baseByte) << 4) + (stoneData[i*2] - baseByte);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    NSUInteger bytesPerRow=bytesPerPixel*width;
    int bitsPerComponent = 8;
    
    UIImage* retImage = nil;
    @autoreleasepool {
        CGContextRef cgContexRef = CGBitmapContextCreate(data,
                                                         width,
                                                         height,
                                                         bitsPerComponent,
                                                         bytesPerRow,
                                                         colorSpace,
                                                         kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
        CGImageRef quartzImage = CGBitmapContextCreateImage(cgContexRef);
        retImage = [UIImage imageWithCGImage:quartzImage];
        
        CGImageRelease(quartzImage);
        CGContextRelease(cgContexRef);
    }
    free(data);
    CGColorSpaceRelease(colorSpace);
    
    return retImage;
}
-(void)getNotification:(NSNotification*)noti{
    _imageView.image = [self createImageFromString:[(NSString*)noti.object stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
