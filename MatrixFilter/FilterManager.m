//
//  FilterManager.m
//  MatrixFilter
//
//  Created by Michael on 31/07/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import "FilterManager.h"

void *bitmap;

@interface FilterManager ()

@end

@implementation FilterManager

static CGContextRef createRGBABitmapContext(CGImageRef image) {
    CGContextRef context = NULL;
    
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    long bitmapByteCount;
    long bitmapBytePerRow;
    
    size_t pixelsWidth = CGImageGetWidth(image);
    size_t pixelsHeight = CGImageGetHeight(image);
    
    bitmapBytePerRow = pixelsWidth * 4;
    bitmapByteCount = bitmapBytePerRow * pixelsHeight;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    bitmapData = malloc(bitmapByteCount);
    
    bitmap = bitmapData;
    
    context = CGBitmapContextCreate(bitmapData, pixelsWidth, pixelsHeight, 8, bitmapBytePerRow, colorSpace, CGImageGetBitmapInfo(image));
    CGColorSpaceRelease(colorSpace);
    
    if (bitmapData == NULL) {
        return NULL;
    }
    
    return context;
}

static unsigned char *requestImagePixelData(UIImage * image) {
    CGImageRef imageRef = [image CGImage];
    CGSize size = [image size];
    
    CGContextRef ctx = createRGBABitmapContext(imageRef);
    CGRect rect = {{0,0},{size.width, size.height}};
    
    CGContextDrawImage(ctx, rect, imageRef);
    unsigned char *data = CGBitmapContextGetData(ctx);
    
    CGContextRelease(ctx);
    ctx = NULL;
    
    return data;
}

- (UIImage *)createImageWithImage:(UIImage *)image colorMatrix:(const float *)f {
    unsigned char *imagePixel = requestImagePixelData(image);
    
    CGImageRef imageRef = [image CGImage];
    long width = CGImageGetWidth(imageRef);
    long height = CGImageGetHeight(imageRef);
    
    int widthOffset = 0;
    int pixOffset = 0;
    
    for (long y = 0; y < height; y++) {
        pixOffset = widthOffset;
        for (long x = 0; x < width; x++) {
            int red = (unsigned char)imagePixel[pixOffset];
            int green = (unsigned char)imagePixel[pixOffset+1];
            int blue = (unsigned char)imagePixel[pixOffset+2];
            int alpha = (unsigned char)imagePixel[pixOffset+3];
            changeRGBA(&red, &green, &blue, &alpha, f);
            imagePixel[pixOffset] = red;
            imagePixel[pixOffset+1] = green;
            imagePixel[pixOffset+2] = blue;
            imagePixel[pixOffset+3] = alpha;
            pixOffset += 4;
        }
        widthOffset += width * 4;
    }
    
    long dataLength = width * height * 4;
    CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, imagePixel, dataLength, NULL);
    
    if (!providerRef) {
        return nil;
    } else {
        int bitsPerComponent = 8;
        int bitsPerPixel = 32;
        ItemCount bytesPerRow = 4 * width;
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
        CGColorRenderingIntent rederingIntent = kCGRenderingIntentDefault;
        
        CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, providerRef, NULL, NO, rederingIntent);
        if (!imageRef) {
            return nil;
        } else {
            UIImage *outPutImage = [UIImage imageWithCGImage:imageRef];
            CFRelease(imageRef);
            CGColorSpaceRelease(colorSpaceRef);
            CGDataProviderRelease(providerRef);
            
            if (self.imageBlock) {
                self.imageBlock(outPutImage);
            }
            
            NSData *data = UIImageJPEGRepresentation(outPutImage, 1.0);
            
            free(bitmap);
            
            return [UIImage imageWithData:data];
        }
    }
    return nil;
}

static void changeRGBA(int *red, int *green, int *blue, int *alpha, const float *f) {
    int redValue = *red;
    int greenValue = *green;
    int blueValue = *blue;
    int alphaValue = *alpha;
    *red = f[0] * redValue + f[1] * greenValue + f[2] * blueValue + f[3] * alphaValue + f[4];
    *green = f[5] * redValue + f[6] * greenValue + f[7] * blueValue + f[8] * alphaValue + f[9];
    *blue = f[10] * redValue + f[11] * greenValue + f[12] *blueValue + f[13] * alphaValue + f[14];
    *alpha = f[15] * redValue + f[16] * greenValue + f[17] * blueValue + f[18] * alphaValue + f[19];
    
    if (*red < 0) *red = 0;
    if (*red > 255) *red = 255;
    
    if (*green < 0) *green = 0;
    if (*green > 255) *green = 255;
    
    if (*blue < 0) *blue = 0;
    if (*blue > 255) *blue = 255;
    
    if (*alpha < 0) *alpha = 0;
    if (*alpha > 255) *alpha = 255;
}

@end
