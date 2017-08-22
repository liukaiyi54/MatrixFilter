//
//  FileManager.m
//  MatrixFilter
//
//  Created by Michael on 22/08/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

static id _instance;

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        [self loadFile];
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"IllegalAccessException" reason:@"Use `+ (instancetype)sharedManager` instead" userInfo:nil];
}

+ (instancetype)sharedInstance {
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] initPrivate];
        }
    }
    return _instance;
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    return documentsDirectory;
}

- (NSString *)dataFilePath {
    return [[self documentsDirectory] stringByAppendingPathComponent:@"File.plist"];
}

- (void)saveFile{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.file forKey:@"File"];
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
}

- (void)loadFile {
    NSString *path = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.file = [unarchiver decodeObjectForKey:@"File"];
        [unarchiver finishDecoding];
    } else {
        self.file = [[NSMutableDictionary alloc] init];
    }
}

@end
