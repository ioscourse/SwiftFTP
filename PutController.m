//
//  PutController.m
//  SwiftFTP
//
//  Created by Charles Konkol on 2015-06-02.
//  Copyright (c) 2015 Rock Valley College. All rights reserved.
//

#import "PutController.h"
#include <CFNetwork/CFNetwork.h>

enum {
    kSendBufferSize = 32768
};

@interface PutController () <NSStreamDelegate>

@property (nonatomic, strong, readwrite) NSOutputStream *  networkStream;
@property (nonatomic, strong, readwrite) NSInputStream *   fileStream;
@property (nonatomic, assign, readonly ) uint8_t *         buffer;
@property (nonatomic, assign, readwrite) size_t            bufferOffset;
@property (nonatomic, assign, readwrite) size_t            bufferLimit;

@end

@implementation PutController
{
    uint8_t _buffer[kSendBufferSize];
}

// Because buffer is declared as an array, you have to use a custom getter.
// A synthesised getter doesn't compile.

- (uint8_t *)buffer
{
    return self->_buffer;
}


- (void)startSend:(NSData *)dataToUpload withURL:(NSURL *)toURL withUsername:(NSString *)username andPassword:(NSString *)password
{
    printf(__FUNCTION__);
    
    self.fileStream = [NSInputStream inputStreamWithData:dataToUpload];
    
    [self.fileStream open];
    
    // Open a CFFTPStream for the URL.
    
    self.networkStream = CFBridgingRelease(
                                           CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) toURL)
                                           );
    
    [self.networkStream setProperty:username forKey:(id)kCFStreamPropertyFTPUserName];
    [self.networkStream setProperty:password forKey:(id)kCFStreamPropertyFTPPassword];
    
    self.networkStream.delegate = self;
    [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.networkStream open];
    
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    printf(__FUNCTION__);
    
    if (self.networkStream != nil) {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our
// network stream.
{
    printf(__FUNCTION__);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            printf("Opened connection");
        } break;
        case NSStreamEventHasBytesAvailable: {
            printf("should never happen for the output stream");
        } break;
        case NSStreamEventHasSpaceAvailable: {
            printf("Sending");
            
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (self.bufferOffset == self.bufferLimit) {
                NSInteger   bytesRead;
                
                bytesRead = [self.fileStream read:self.buffer maxLength:kSendBufferSize];
                
                if (bytesRead == -1) {
                    [self stopSendWithStatus:@"File read error"];
                } else if (bytesRead == 0) {
                    [self stopSendWithStatus:nil];
                } else {
                    self.bufferOffset = 0;
                    self.bufferLimit  = bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            
            if (self.bufferOffset != self.bufferLimit) {
                NSInteger   bytesWritten;
                bytesWritten = [self.networkStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [self stopSendWithStatus:@"Network write error"];
                } else {
                    self.bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            [self stopSendWithStatus:@"Stream open error"];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}

@end