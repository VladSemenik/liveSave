//
//  ViewController.m
//  liveSave
//
//  Created by Владислав Семеник on 11/29/19.
//  Copyright © 2019 Владислав Семеник. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import <CoreMedia/CMMetadata.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVKit/AVKit.h>

@interface ViewController ()

@end

@implementation ViewController {
    AVAssetReader *reader;
    AVAssetWriter *writer;
    dispatch_group_t group;
    dispatch_queue_t queue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    BOOL available = [PHAssetCreationRequest supportsAssetResourceTypes:@[@(PHAssetResourceTypePhoto), @(PHAssetResourceTypePairedVideo)]];
    if (!available) {
        NSLog(@"No permission to save");
        return;
    }

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            NSLog(@"Photo Library access denied.");
            return;
        }
    }];
    
//    NSString *photoPath = @"https://res.cloudinary.com/vls-vls/image/upload/v1574247167/app/6p0602_gqhbbc.jpg";
//    NSString *videoPath = @"https://res.cloudinary.com/vls-vls/video/upload/v1574247177/app/6p0602_arqv6s.mov";
//
//    NSURL *photo = [NSURL URLWithString:photoPath];
//    NSURL *video = [NSURL URLWithString:videoPath];
//
//    if (![self isFileStoredInCache:[[photoPath componentsSeparatedByString:@"/"] lastObject]]) {
//        [self downloadTaskWithURL:photo];
//    }
//    if (![self isFileStoredInCache:[[videoPath componentsSeparatedByString:@"/"] lastObject]]) {
//        [self downloadTaskWithURL:video];
//    }
//
//    NSLog(@"%@ %@", [self readFile: [[photoPath componentsSeparatedByString:@"/"] lastObject]],
//          [self readFile: [[photoPath componentsSeparatedByString:@"/"] lastObject]]);
    
//    [self logDerictoryContentAtPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]];
    [self logDerictoryContentAtPath: @"/Users/vls/Desktop"];
    
//    NSURL * ph = [NSURL URLWithString: [NSString stringWithFormat:@"file://%@/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject], [[photoPath componentsSeparatedByString:@"/"] lastObject]]];
//    NSURL * vd = [NSURL URLWithString: [NSString stringWithFormat:@"file://%@/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject], [[videoPath componentsSeparatedByString:@"/"] lastObject]]];
    
    NSURL * ph = [NSURL URLWithString: @"file:///Users/vls/Desktop/6p0602.jpg"];
    NSURL * vd = [NSURL URLWithString: @"file:///Users/vls/Desktop/6p0602.mov"];
//
    
    NSURL * ph1 = [NSURL URLWithString: @"file:///Users/vls/Desktop/img.jpg"];
    NSURL * vd1 = [NSURL URLWithString: @"file:///Users/vls/Desktop/img.mov"];
    
    [self useAssetWriter:ph video:vd identifier:@"name" complete:^(BOOL success, NSString *photoFile, NSString *videoFile, NSError *error) {
        if(success) {
            NSLog(@"success");
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                [request addResourceWithType: PHAssetResourceTypePhoto fileURL: ph1 options: nil];
                [request addResourceWithType: PHAssetResourceTypePairedVideo fileURL:vd1 options:nil];

            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success) { NSLog(@"Saved."); }
                else { NSLog(@ "Save error: %@", error); }
            }];
        } else if(error){
            NSLog(@"error");
        }
    }];
    
    
    
//    NSData *imagedata = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject], [[photoPath componentsSeparatedByString:@"/"] lastObject]]];
//    CGImageSourceRef source = CGImageSourceCreateWithData((CFMutableDataRef)imagedata, NULL);
//    NSDictionary *metadata = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source,0,NULL));
//
//    NSLog(@"%@", metadata);
    
    
}

#pragma mark - methods for cache

- (void)log {
    NSLog(@"log");
}

- (void)storingImageIntoCache:(NSData*)imageData byName:(NSString*)name {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", cachePath, name];
    [[NSFileManager defaultManager] createFileAtPath: filePath contents: imageData attributes: nil];
}

- (BOOL)isFileStoredInCache:(NSString*)name {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *cacheFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:nil];
    if ([cacheFiles containsObject:name]) {
        return YES;
    }
    return NO;
}

- (NSData*)readFile:(NSString*)name {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", cachePath, name];
    return [[NSFileManager defaultManager] contentsAtPath:filePath];
}

- (void)downloadTaskWithURL:(NSURL*)URL {
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request
                                                         completionHandler:
    ^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSLog(@"error, %@", error);
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/", documentsPath]];
        NSURL *documentURL = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        [[NSFileManager defaultManager] moveItemAtURL:location
                                                toURL:documentURL
                                                error:nil];
        
        [self logDerictoryContentAtPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]];
      }];
    [downloadTask resume];
    
    NSLog(@"download started");
}

- (void)logDerictoryContentAtPath:(NSString*)path {
    NSFileManager *filemgr;
    NSArray *filelist;
    int count;
    int i;

    filemgr = [NSFileManager defaultManager];

    filelist = [filemgr contentsOfDirectoryAtPath:path error: nil];

    count = [filelist count];

    for (i = 0; i < count; i++)
            NSLog (@"%d %@", i, [filelist objectAtIndex: i]);
}

- (void)createDirectoryInCache:(NSString*)name {
    NSFileManager *filemgr;
    filemgr = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    [filemgr createDirectoryAtURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@/", cachePath, name]] withIntermediateDirectories:YES attributes: nil error:nil];
}

- (void)deleteFile:(NSString*)path {
    NSFileManager *filemgr;
    filemgr = [NSFileManager defaultManager];
    if ([filemgr removeItemAtPath: path error: NULL]  == YES)
            NSLog (@"Remove successful");
    else
            NSLog (@"Remove failed");
}

#pragma mark end methods for cache -

- (void)addMetadataToPhoto:(NSURL *)photoURL outputPhotoFile:(NSString *)outputFile identifier:(NSString *)identifier {
    NSMutableData *data = [NSData dataWithContentsOfURL:photoURL].mutableCopy;
    UIImage *image = [UIImage imageWithData:data];
    CGImageRef imageRef = image.CGImage;
    NSDictionary *imageMetadata = @{
        (NSString *)kCGImagePropertyMakerAppleDictionary : @{@"17" : identifier},
    };
    CGImageDestinationRef dest = CGImageDestinationCreateWithData((CFMutableDataRef)data, kUTTypeJPEG, 1, nil);
    CGImageDestinationAddImage(dest , imageRef, (CFDictionaryRef)imageMetadata);
    CGImageDestinationFinalize(dest);
    [data writeToFile:outputFile atomically:YES];
}

- (AVMetadataItem *) createContentIdentifierMetadataItem: (NSString *) identifier {
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.keySpace = AVMetadataKeySpaceQuickTimeMetadata;
    item.key = AVMetadataQuickTimeMetadataKeyContentIdentifier;
    item.value = identifier;
    return item;
}

- (AVAssetWriterInput *) createStillImageTimeAssetWriterInput {
    NSArray *spec = @[@{(NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier : @"mdta/com.apple.quicktime.still-image-time",
                        (NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType: (NSString *)kCMMetadataBaseDataType_SInt8} ];
    CMFormatDescriptionRef desc = NULL;
    CMMetadataFormatDescriptionCreateWithMetadataSpecifications (kCFAllocatorDefault, kCMMetadataFormatType_Boxed, (__bridge CFArrayRef) spec, & desc);
    AVAssetWriterInput *INPUT = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:desc];
    return INPUT;
}

- (AVMetadataItem *) createStillImageTimeMetadataItem {
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.keySpace = AVMetadataKeySpaceQuickTimeMetadata;
    item.key = @"com.apple.quicktime.still-image-time";
    item.value = @(-1);
    item.dataType = (NSString *) kCMMetadataBaseDataType_SInt8;
    return item;
}

- (void)addMetadataToVideo:(NSURL *)videoURL outputFile:(NSString *)outputFile identifier:(NSString *)identifier {
    NSError *error = nil;
      
    // Reader
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    if (error) {
        NSLog(@"Init reader error: %@", error);
        return;
    }
      
    // Add content identifier metadata item
    NSMutableArray<AVMetadataItem *> *metadata = asset.metadata.mutableCopy;
    AVMetadataItem *item = [self createContentIdentifierMetadataItem:identifier];
    [metadata addObject:item];
      
    // Writer
    NSURL *videoFileURL = [NSURL fileURLWithPath:outputFile];
    [self deleteFile:outputFile];
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:videoFileURL fileType:AVFileTypeQuickTimeMovie error:&error];
    if (error) {
        NSLog(@"Init writer error: %@", error);
        return;
    }
    [writer setMetadata:metadata];
    
    // Tracks
    NSArray<AVAssetTrack *> *tracks = [asset tracks];
    for (AVAssetTrack *track in tracks) {
        NSDictionary *readerOutputSettings = nil;
        NSDictionary *writerOuputSettings = nil;
        if ([track.mediaType isEqualToString:AVMediaTypeAudio]) {
            readerOutputSettings = @{AVFormatIDKey : @(kAudioFormatLinearPCM)};
            writerOuputSettings = @{AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                    AVSampleRateKey : @(44100),
                                    AVNumberOfChannelsKey : @(2),
                                    AVEncoderBitRateKey : @(128000),
            };
        }
        AVAssetReaderTrackOutput *output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:readerOutputSettings];
        AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:track.mediaType outputSettings:writerOuputSettings];
        if ([reader canAddOutput:output] && [writer canAddInput:input]) {
            [reader addOutput :output];
            [writer addInput:input];
        }
    }
    
    // Metadata track
    AVAssetWriterInput *input = [self createStillImageTimeAssetWriterInput];
    AVAssetWriterInputMetadataAdaptor *adaptor = [AVAssetWriterInputMetadataAdaptor assetWriterInputMetadataAdaptorWithAssetWriterInput:input];
    if ([writer canAddInput:input]) {
        [writer addInput:input];
    }
    
    // Start reading and writing
    [writer startWriting];
    [writer startSessionAtSourceTime:kCMTimeZero];
    [reader startReading];
    
    // Write metadata track's metadata
    AVMetadataItem *timedItem = [self createStillImageTimeMetadataItem];
    CMTimeRange timedRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(1, 100));
    AVTimedMetadataGroup *timedMetadataGroup = [[AVTimedMetadataGroup alloc] initWithItems:@[timedItem] timeRange:timedRange];
    [adaptor appendTimedMetadataGroup:timedMetadataGroup];
    
    // Write other tracks
    self->reader = reader;
    self->writer = writer;
    self->queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self->group = dispatch_group_create();
    for (NSInteger i = 0; i < reader.outputs.count ; ++i) {
        dispatch_group_enter(self->group);
        [self writeTrack:i];
    }
}

- (void)writeTrack:(NSInteger)trackIndex {
    AVAssetReaderOutput *output = reader.outputs[trackIndex];
    AVAssetWriterInput *input = writer.inputs[trackIndex];
    [input requestMediaDataWhenReadyOnQueue:self->queue usingBlock:^{
        while ( input.readyForMoreMediaData) {
            AVAssetReaderStatus status = self->reader.status;
            CMSampleBufferRef buffer = NULL;
            if ((status == AVAssetReaderStatusReading) &&
                (buffer = [output copyNextSampleBuffer])) {
                BOOL success = [input appendSampleBuffer:buffer];
                CFRelease( buffer);
                if (!success) {

                    NSLog(@"Track %d. Failed to append buffer.", (int)trackIndex);
                    [input markAsFinished];
                    dispatch_group_leave(self->group);
                    return;
                }
            } else {
                if (status == AVAssetReaderStatusReading) {
                    NSLog(@ "Track %d complete.", (int)trackIndex);
                } else if (status == AVAssetReaderStatusCompleted) {
                    NSLog(@"Reader completed.");
                } else if (status == AVAssetReaderStatusCancelled) {
                    NSLog(@"Reader cancelled .");
                } else if (status == AVAssetReaderStatusFailed) {
                    NSLog(@"Reader failed.");
                }
                [input markAsFinished];
                dispatch_group_leave(self->group);
                return;
            }
        }
    }];
}
                          
- (void)finishWritingTracksWithPhoto:(NSString *)photoFile video:(NSString *)videoFile complete:(void (^)(BOOL success, NSString *photoFile, NSString *videoFile, NSError *error))complete {
    [self->reader cancelReading] ;
    [self->writer finishWritingWithCompletionHandler:^{
        if (complete) complete(YES, photoFile, videoFile, nil);
    }];
}
                          
- (void)useAssetWriter:(NSURL *)photoURL video:(NSURL *)videoURL identifier:(NSString *)identifier complete:(void (^)(BOOL success, NSString *photoFile, NSString *videoFile, NSError *error))complete {
    // Photo
    NSString *photoName = [photoURL lastPathComponent];
    NSString *photoFile = @"/Users/vls/Desktop/img.jpg";
    [self addMetadataToPhoto:photoURL outputPhotoFile:photoFile identifier:identifier];
//     Video
    NSString *videoName = [videoURL lastPathComponent];
    NSString *videoFile = @"/Users/vls/Desktop/img.mov";
    [self addMetadataToVideo:videoURL outputFile:videoFile identifier:identifier];
    if (!self->group) return;
    dispatch_group_notify(self->group, dispatch_get_main_queue(), ^{
        [self finishWritingTracksWithPhoto:photoFile video:videoFile complete:complete];
    });
}

@end
