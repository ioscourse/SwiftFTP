//
//  PutController.h
//  SwiftFTP
//
//  Created by Charles Konkol on 2015-06-02.
//  Copyright (c) 2015 Rock Valley College. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PutController : NSObject

- (void)startSend:(NSData *)dataToUpload withURL:(NSURL *)toURL withUsername:(NSString *)username andPassword:(NSString *)password;
@end