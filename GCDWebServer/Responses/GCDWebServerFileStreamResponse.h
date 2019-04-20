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

#import "GCDWebServerResponse.h"

NS_ASSUME_NONNULL_BEGIN

//open and return priv data
typedef id _Nullable(^openBlock)(void);
typedef NSInteger(^getSizeBlock)(void);
typedef BOOL(^seekBlock)(NSInteger);
typedef NSData* _Nullable(^readBlock)(NSInteger);
typedef void(^closeBlock)(void);

/**
 *  The GCDWebServerFileStreamResponse subclass of GCDWebServerResponse reads the body
 *  of the HTTP response from a file on disk.
 *
 *  It will automatically set the contentType, lastModifiedDate and eTag
 *  properties of the GCDWebServerResponse according to the file extension and
 *  metadata.
 */
@interface GCDWebServerFileStreamResponse : GCDWebServerResponse
@property(nonatomic, copy) NSString* contentType;  // Redeclare as non-null
@property(nonatomic) NSDate* lastModifiedDate;  // Redeclare as non-null
@property(nonatomic, copy) NSString* eTag;  // Redeclare as non-null
@property(nonatomic, copy) NSString* ext;  // Redeclare as non-null
@property(nonatomic, copy) NSString* desc;  // Redeclare as non-null
@property(nonatomic) id privData;
@property(nonatomic) openBlock onOpen;
@property(nonatomic) getSizeBlock onGetSize;
@property(nonatomic) seekBlock onSeek;
@property(nonatomic) readBlock onRead;
@property(nonatomic) closeBlock onClose;

+ (nullable instancetype)responseWithOpenBlock:(openBlock)open
                                  getSizeBlock:(getSizeBlock)getSize
                                     seekBlock:(seekBlock)seek
                                     readBlock:(readBlock)read
                                    closeBlock:(closeBlock)close
                                     extension:(NSString*)ext
                                         range:(NSRange)byteRange;
- (nullable instancetype)initWithOpenBlock:(openBlock)open
                              getSizeBlock:(getSizeBlock)getSize
                                 seekBlock:(seekBlock)seek
                                 readBlock:(readBlock)read
                                closeBlock:(closeBlock)close
                                 extension:(NSString*)ext
                                     range:(NSRange)byteRange;
@end

NS_ASSUME_NONNULL_END
