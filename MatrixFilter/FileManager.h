//
//  FileManager.h
//  MatrixFilter
//
//  Created by Michael on 22/08/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *file;

+ (instancetype)sharedInstance;

- (void)saveFile;

@end
