//
//  VGViewController.m
//  testFrom
//
//  Created by JiangHuifu on 14-6-17.
//  Copyright (c) 2014年 veger. All rights reserved.
//

#import "VGViewController.h"

@interface VGViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation VGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIImagePickerControllerDelegate
-(NSString*)createFromImage:(UIImage*)image{
    CGImageRef imageRef= [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow=bytesPerPixel*width;
    int bitsPerComponent = 8;
    NSUInteger imageLength = (4*(width-1)+4*(height-1)*width+3);
    
    CGContextRef cgContexRef = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    
    CGRect theRect = CGRectMake(0,0, width, height);
    CGContextDrawImage(cgContexRef, theRect, imageRef);
    
    //Byte* tempData=(Byte*)CGBitmapContextGetData(cgContexRef);
    CGColorSpaceRelease(colorSpace);
    
    Byte* imageData = (Byte*)CGBitmapContextGetData(cgContexRef);
    
    Byte* stoneData = (Byte*)malloc(sizeof(Byte)*imageLength*2 + 1);
    Byte baseByte = (Byte)'a';
    for (NSUInteger i = 0; i<imageLength; i++) {
        stoneData[i*2] = (imageData[i]&0x0f) + baseByte;
        stoneData[i*2+1] = (imageData[i] >> 4) + baseByte;
    }
    CGContextRelease(cgContexRef);
    stoneData[imageLength*2] = (Byte)'\0';
    NSString* retString = [NSString stringWithFormat:@"{\"width\":%d,\"height\":%d,\"content\":\"%s\"}",width,height,stoneData];
    free(stoneData);
    return retString;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString* str = [NSString stringWithFormat:@"todolist://www.acme.com?%@",[self createFromImage:image]];
        NSLog(@"%d",str.length);
        NSURL *myURL = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:myURL];
    }];
}
@end
