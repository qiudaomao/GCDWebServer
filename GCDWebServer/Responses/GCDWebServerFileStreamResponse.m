/*
 Copyright (c) 2012-2019, Pierre-Olivier Latour
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * The name of Pierre-Olivier Latour may not be used to endorse
 or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL PIERRE-OLIVIER LATOUR BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#if !__has_feature(objc_arc)
#error GCDWebServer requires ARC
#endif

#import <sys/stat.h>
#import "GCDWebServerFileStreamResponse.h"
#import "GCDWebServerPrivate.h"

#define kFileReadBufferSize (32 * 1024)

@implementation GCDWebServerFileStreamResponse {
    NSUInteger _offset;
    NSUInteger _size;
    BOOL opened;
}

@dynamic contentType, lastModifiedDate, eTag;
@synthesize ext;
@synthesize desc;

+ (nullable instancetype)responseWithOpenBlock:(openBlock)open
                                  getSizeBlock:(getSizeBlock)getSize
                                     seekBlock:(seekBlock)seek
                                     readBlock:(readBlock)read
                                    closeBlock:(closeBlock)close
                                     extension:(NSString*)ext {
    return [[GCDWebServerFileStreamResponse alloc] initWithOpenBlock:open
                                                        getSizeBlock:getSize
                                                           seekBlock:seek
                                                           readBlock:read
                                                          closeBlock:close
                                                           extension:ext];
}

- (nullable instancetype)initWithOpenBlock:(openBlock)open
                              getSizeBlock:(getSizeBlock)getSize
                                 seekBlock:(seekBlock)seek
                                 readBlock:(readBlock)read
                                closeBlock:(closeBlock)close
                                 extension:(NSString*)ext {
    if ((self = [super init])) {
        self.onOpen = open;
        self.onGetSize = getSize;
        self.onSeek = seek;
        self.onRead = read;
        self.onClose = close;
    }
    _offset = 0;
    opened = NO;
    NSError *err;
    [self open:&err];
    if (err) {
        return nil;
    }
    return self;
}

- (BOOL)open:(NSError**)error {
    if (!opened) {
        opened = YES;
        id priv = self.onOpen();
        if (!priv) return NO;
        self.privData = priv;
    }
    NSUInteger size = self.onGetSize();
    _size = size;
    self.contentLength = _size;
    if (_size<=0) return NO;
    [self setStatusCode:kGCDWebServerHTTPStatusCode_PartialContent];
    NSString *rangestr = [NSString stringWithFormat:@"bytes %lu-%lu/%lu", (unsigned long)_offset, (unsigned long)(_offset + _size - 1), (unsigned long)size];
    [self setValue:rangestr forAdditionalHeader:@"Content-Range"];
    self.contentType = GCDWebServerGetMimeTypeForExtension(self.ext, nil);
    if (self.onSeek(0)) {
        self.onClose();
        return NO;
    }
    return YES;
}

- (NSData*)readData:(NSError**)error {
    size_t length = MIN((NSUInteger)kFileReadBufferSize, _size);
    NSData *data = self.onRead(length);
    return data;
}

- (void)close {
    self.onClose();
}

- (NSString*)description {
  NSMutableString* description = [NSMutableString stringWithString:[super description]];
  [description appendFormat:@"\n\n{%@}", self.desc];
  return description;
}

@end
