//
//  ProgressDelegate.h
//  ObjectiveCExample
//
//  Created by Antoine Cœur on 04/10/2017.
//

#import <Foundation/Foundation.h>

#if COCOAPODS
#import <SSZipArchive.h>
#else
#import "ZipArchive.h"
#endif


@interface ProgressDelegate : NSObject <SSZipArchiveDelegate>
{
@public
    NSMutableArray<NSValue*> *fileInfos;
    NSMutableArray<NSNumber*> *progressEvents;
}

@end
