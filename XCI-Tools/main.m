//
//  main.m
//  XCI-Tools
//
//  Created by 徐红明 on 2018/7/19.
//  Copyright © 2018年 徐红明. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#import "Trim.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf("XCI Tools v0.1b\n");
        BOOL info = false;
        BOOL usage = false;
        NSMutableArray *fileNames = [NSMutableArray array];
        for (int i = 1; i < argc; i++) {
            NSString *arg = [NSString stringWithFormat:@"%s", argv[i]];
            if ([arg isEqualToString:@"--info"] || [arg isEqualToString:@"-i"])
                info = true;
            if ([arg isEqualToString:@"--help"] || [arg isEqualToString:@"-h"])
                usage = true;
            if (![arg hasPrefix:@"-"] && [[arg lowercaseString] hasSuffix:@".xci"]) {
                [fileNames addObject:arg];
            }
        }
        if (usage) {
            printf("Usage: xci-tools [file...] [options...]\n\nOptions:\n");
            printf("-i, --info\t\tOnly show XCI file info.\n");
            printf("-h, --help\t\tThis screen.\n\n");
            return 0;
        }
        if ([fileNames count] == 0) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString* path = [fileManager currentDirectoryPath];
            NSArray * paths = [fileManager subpathsOfDirectoryAtPath:path error:NULL];
            [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull fileName, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![fileName hasPrefix:@"."] && [[fileName lowercaseString] hasSuffix:@".xci"])
                    [fileNames addObject:fileName];
            }];
        }
        if ([fileNames count] == 0) {
            printf("Can not found XCI file(s).\n\n");
            return 0;
        }
        [fileNames enumerateObjectsUsingBlock:^(NSString * _Nonnull fileName, NSUInteger idx, BOOL * _Nonnull stop) {
            [[Trim new] trim:fileName showinfo:info];
        }];
    }
    return 0;
}
