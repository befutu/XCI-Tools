//
//  Trim.m
//  XCI-Tools
//
//  Created by 徐红明 on 2018/7/19.
//  Copyright © 2018年 徐红明. All rights reserved.
//


#include <stdio.h>
#import "Trim.h"

@implementation Trim

- (NSArray *)capacitys {
    NSArray *array = [NSArray arrayWithObjects:@"B", @"KB", @"MB", @"GB", @"TB", nil];
    return array;
}

-(void)trim:(NSString *)fileName showinfo:(BOOL)info {
    printf("XCI file name: %s\n", [fileName cStringUsingEncoding:NSUTF8StringEncoding]);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fileName isDirectory:false]) {
        printf("\tFile not found!\n\n");
        return;
    }
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:fileName error:NULL];
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:fileName];
    NSData *data = [handle readDataOfLength:512];
    [handle closeFile];
    
    Byte *bytes = (Byte *)[data bytes];
    Byte cardSize1 = bytes[269];
    unsigned long long cardSize2 = bytes[280] + (bytes[281] << 8) + (bytes[282] << 16) + (bytes[283] << 24);
    cardSize2 += ((unsigned long long)bytes[284] << 32) + ((unsigned long long)bytes[285] << 40) + ((unsigned long long)bytes[286] << 48) + ((unsigned long long)bytes[287] << 56);
    cardSize2 = cardSize2 * 512 + 512;
    unsigned long long fileSize = [attrs[@"NSFileSize"] unsignedLongLongValue];
    printf("\tMemoryCard Capacity: %s\n", [[self getCapacity:cardSize1] cStringUsingEncoding:NSUTF8StringEncoding]);
    printf("\tFile size: %llu(%s)\n", fileSize, [[self calcCapacity:fileSize] cStringUsingEncoding:NSUTF8StringEncoding]);
    printf("\tUsed Space: %llu(%s)\n", cardSize2, [[self calcCapacity:cardSize2] cStringUsingEncoding:NSUTF8StringEncoding]);
    if (info) {
        printf("\n");
        return;
    }
    if (fileSize > cardSize2) {
        NSFileHandle *writeHandle = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        [writeHandle truncateFileAtOffset:cardSize2];
        [writeHandle closeFile];
        unsigned long long truns = fileSize - cardSize2;
        printf("\tFile truncated: %llu(%s)\n\n", truns, [[self calcCapacity:truns] cStringUsingEncoding:NSUTF8StringEncoding]);
    } else {
        printf("\tNo verbose space!\n\n");
    }
}

- (NSString *)calcCapacity:(unsigned long long)size {
    NSArray *capacitys = [self capacitys];
    double num = (double)size;
    int num2 = 0;
    
    while (num >= 1024. && num2 < [capacitys count] - 1) {
        num2++;
        num /= 1024.;
    }
    return [NSString stringWithFormat:@"%.2f%@", num, capacitys[num2]];
}

- (NSString *)getCapacity:(int)val {
    switch (val) {
        case 248:
            return @"2GB";
        case 240:
            return @"4GB";
        case 224:
            return @"8GB";
        case 225:
            return @"16GB";
        case 226:
            return @"32GB";
        default:
            return @"?";
            break;
    }
}

@end
