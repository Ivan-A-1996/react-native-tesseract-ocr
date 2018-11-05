
#import "RNTesseractOcr.h"
#import "RCTLog.h"
#import "GPUImage.h"

@implementation RNTesseractOcr  {
    G8Tesseract *_tesseract;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (NSString*) getConstants:(NSString*)language  {
    NSDictionary *wordDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"afr", @"LANG_AFRIKAANS",
                                        @"amh", @"LANG_AMHARIC",
                                        @"ara", @"LANG_ARABIC",
                                        @"asm", @"LANG_ASSAMESE",
                                        @"aze", @"LANG_AZERBAIJANI",
                                        @"bel", @"LANG_BELARUSIAN",
                                        @"bos", @"LANG_BOSNIAN",
                                        @"bul", @"LANG_BULGARIAN",
                                        @"chi_sim", @"LANG_CHINESE_SIMPLIFIED",
                                        @"chi_tra", @"LANG_CHINESE_TRADITIONAL",
                                        @"hrv", @"LANG_CROATIAN",
                                        @"custom", @"LANG_CUSTOM",
                                        @"dan", @"LANG_DANISH",
                                        @"eng", @"LANG_ENGLISH",
                                        @"est", @"LANG_ESTONIAN",
                                        @"fra", @"LANG_FRENCH",
                                        @"glg", @"LANG_GALICIAN",
                                        @"deu", @"LANG_GERMAN",
                                        @"heb", @"LANG_HEBREW",
                                        @"hun", @"LANG_HUNGARIAN",
                                        @"isl", @"LANG_ICELANDIC",
                                        @"ind", @"LANG_INDONESIAN",
                                        @"gle", @"LANG_IRISH",
                                        @"ita", @"LANG_ITALIAN",
                                        @"jpn", @"LANG_JAPANESE",
                                        @"kor", @"LANG_KOREAN",
                                        @"lat", @"LANG_LATIN",
                                        @"lit", @"LANG_LITHUANIAN",
                                        @"nep", @"LANG_NEPALI",
                                        @"nor", @"LANG_NORWEGIAN",
                                        @"fas", @"LANG_PERSIAN",
                                        @"pol", @"LANG_POLISH",
                                        @"por", @"LANG_PORTUGUESE",
                                        @"rus", @"LANG_RUSSIAN",
                                        @"srp", @"LANG_SERBIAN",
                                        @"slk", @"LANG_SLOVAK",
                                        @"spa", @"LANG_SPANISH",
                                        @"swe", @"LANG_SWEDISH",
                                        @"tur", @"LANG_TURKISH",
                                        @"ukr", @"LANG_UKRAINIAN",
                                        @"vie", @"LANG_VIETNAMESE", nil];
    return [wordDictionary valueForKey: language];
}

RCT_EXPORT_MODULE()
RCT_EXPORT_METHOD(recognize:(nonnull NSString*)path
                  language:(nonnull NSString*)language
                  options:(nullable NSDictionary*)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    RCTLogInfo(@"starting Ocr");

    _tesseract = [[G8Tesseract alloc] initWithLanguage: [self getConstants:language]];
//    _tesseract.image = [[UIImage imageWithData:[NSData dataWithContentsOfFile:path]] g8_blackAndWhite];

    UIImage *originImg = [UIImage imageNamed:path];
    _tesseract.image = [self processImage:originImg];

    _tesseract.engineMode = G8OCREngineModeTesseractOnly;
    _tesseract.pageSegmentationMode = G8PageSegmentationModeAuto;
    //_tesseract.delegate = self;

    if(options != NULL) {
        NSString *whitelist = [options valueForKey:@"whitelist"];
        if(![whitelist isEqual: [NSNull null]] && [whitelist length] > 0){
            _tesseract.charWhitelist = whitelist;
        }

        NSString *blacklist = [options valueForKey:@"blacklist"];
        if(![blacklist isEqual: [NSNull null]] && [blacklist length] > 0){
            _tesseract.charBlacklist = blacklist;
        }

//        NSString *characterChoices = [options valueForKey:@"characterChoices"];
//        if([blacklist length] > 0){
//            _tesseract.characterChoices = blacklist;
//        }
    }

    BOOL success = _tesseract.recognize;
    NSString *recognizedText = _tesseract.recognizedText;

//    NSArray *characterBoxes = [_tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelSymbol];
//    NSMutableArray *boxes = [[NSMutableArray alloc] initWithCapacity:characterBoxes.count];
//
//    for (G8RecognizedBlock *block in characterBoxes) {
//        [boxes addObject:@{
//                           @"text" : block.text,
//                           @"boundingBox" : @{
//                                   @"x": [NSNumber numberWithFloat:block.boundingBox.origin.x],
//                                   @"y": [NSNumber numberWithFloat:block.boundingBox.origin.y],
//                                   @"width": [NSNumber numberWithFloat:block.boundingBox.size.width],
//                                   @"height": [NSNumber numberWithFloat:block.boundingBox.size.height]
//                                   },
//                           @"confidence" : [NSNumber numberWithFloat:block.confidence],
//                           @"level" : [NSNumber numberWithInt:block.level]
//                           }];
//    }

    resolve([NSString stringWithFormat:@"%@", recognizedText]);

    // reject(@"no_events", @"There were no events", error);
}

- (UIImage*) processImage:(UIImage*)image  {
    // Create image rectangle with current image width/height
//    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
//
//    // Grayscale color space
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
//
//    // Create bitmap content with current image size and grayscale colorspace
//    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
//
//    // Draw image into current context, with specified rectangle
//    // using previously defined context (with grayscale colorspace)
//    CGContextDrawImage(context, imageRect, [image CGImage]);
//
//    // Create bitmap image info from pixel data in current context
//    CGImageRef imageRef = CGBitmapContextCreateImage(context);
//
//    // Create a new UIImage object
//    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
//
//    // Release colorspace, context and bitmap information
//    CGColorSpaceRelease(colorSpace);
//    CGContextRelease(context);
//    CFRelease(imageRef);

    // Initialize our adaptive threshold filter
    GPUImageAdaptiveThresholdFilter *stillImageFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    stillImageFilter.blurRadiusInPixels = 12.0; // adjust this to tweak the blur radius of the filter, defaults to 4.0

    // Retrieve the filtered image from the filter
    UIImage *newImage = [stillImageFilter imageByFilteringImage:image];

    return newImage;
}

@end

