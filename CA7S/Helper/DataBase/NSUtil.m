//
//  NSUtil.m
//  Anoopam Mission
//
//  Created by Darshit Zalavadiya on 10/11/16.
//  Copyright © 2016 Darshit Zalavadiya. All rights reserved.
//


#import "NSUtil.h"
#import "PreventBackup.h"
#import <sys/utsname.h>
#import <sys/sysctl.h>


@implementation NSUtil

+(NSString*)getJsonStringFromDictionary:(NSDictionary*)dictionary{
    NSString *jsonString=@"";
    @try {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        if (!jsonData) {
            NSLog(@"JsonError: %@", error);
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"exception: %@", exception);
    }
    @finally {
        
    }
    return jsonString;
}
+(NSArray*)shortDirectoryArray:(NSArray*)arrayToShort ByKey:(NSString*)key{
    @try {
        return [[arrayToShort sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [((NSDictionary*)a) valueForKey:key];
            NSString *second = [((NSDictionary*)b) valueForKey:key];
            return [first compare:second];
        }] mutableCopy];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

+ (NSURL *)getPath:(NSString *)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSURL *pathURL= [NSURL fileURLWithPath:[documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",path]]];
    return pathURL;
}


+(NSString*)convertDate:(NSString*)dateToConvert
{
    NSString *dateString = @"";
    @try {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSDate *date = [dateFormat dateFromString:dateToConvert];
        
        // Convert date object to desired output format
        [dateFormat setDateFormat:@"MM-dd-yy"];
        dateString = [dateFormat stringFromDate:date];
        return dateString;
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }

    
}
+(NSString*)convertDate:(NSString*)dateToConver dateFormate:(NSString*)dateFormate dateFormateToConvert:(NSString*)dateFormateToConvert{
    @try {
        NSDateFormatter* formatterUtc = [[NSDateFormatter alloc] init];
        [formatterUtc setDateFormat:dateFormate];
        
        NSDate* utcDate = [formatterUtc dateFromString:dateToConver];
        
        NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
        NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        
        NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:utcDate];
        NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:utcDate];
        NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
        
        NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:utcDate];
        
        NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
        [dateFormatters setDateFormat:dateFormateToConvert];
        [dateFormatters setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *dateStr = [dateFormatters stringFromDate: destinationDate];
//        NSLog(@"Converted Date : %@", dateStr);
        return dateStr;
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }    
}

+(NSString*)convertDateTimeStamp:(NSString*)timestamp DateFormat:(NSString*)dateFormat
{
    @try
    {
        double unixTime=[timestamp doubleValue];
        NSTimeInterval _interval=unixTime;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
        NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
        [_formatter setLocale:[NSLocale currentLocale]];
        [_formatter setDateFormat:dateFormat];
        NSString *_date=[_formatter stringFromDate:date];
        return _date;
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

+(CATransition *)pushViewFromLeft:(UITableView*)newView
{
    @try
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.40;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionMoveIn;
        transition.subtype= kCATransitionFromLeft;
        
        [newView.layer addAnimation:transition forKey:nil];
        
        
        return transition;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception:- %@",exception);
    }
    @finally
    {
    }
}
+(CATransition *)pushViewFromright:(UITableView*)newView
{
    @try
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.40;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionMoveIn;
        transition.subtype= kCATransitionFromRight;
        
        [newView.layer addAnimation:transition forKey:nil];
        
        return transition;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception:- %@",exception);
    }
    @finally
    {
    }
}
+(CATransition *)pushViewFromTop:(UITableView *)newView
{
    @try
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionMoveIn;
        transition.subtype= kCATransitionFromTop;
        
        [newView.layer addAnimation:transition forKey:nil];
        
        
        return transition;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception:- %@",exception);
    }
    @finally
    {
    }
}
+(CATransition *)pushViewFromBottom:(UITableView*)newView
{
    @try
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.40;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionMoveIn;
        transition.subtype= kCATransitionFromBottom;
        
        [newView.layer addAnimation:transition forKey:nil];
        
        return transition;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception:- %@",exception);
    }
    @finally
    {
    }
}

+(UIActivityIndicatorView *)setSpinner :(UIActivityIndicatorView *)spinner
{
    @try
    {
        float width = [UIScreen mainScreen].bounds.size.width;
        float height = [UIScreen mainScreen].bounds.size.height;
        
        spinner.frame = CGRectMake((width-37)/2, (height-37)/2, 37, 37);
        
        return spinner;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception:- %@",exception);
    }
    @finally
    {
    }
}

+(UITextField *) addPaddingOnTextField :(UITextField *)txtField
{
    @try
    {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, txtField.frame.size.height)];
        txtField.leftView = paddingView;
        txtField.leftViewMode = UITextFieldViewModeAlways;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception:- %@",exception);
    }
    @finally
    {
    }
    return txtField;
}

+(UITextField *)setPlaceHolderColorOnTextField :(UITextField *)txtField
{
    @try
    {
        [txtField setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
        [txtField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception:- %@",exception);
    }
    @finally
    {
    }
    return txtField;
}

+(id)setBorderRadius:(id)view
{
    [view layer].cornerRadius = 2.0;
    [view setClipsToBounds:true];
    
    return view;
}

+(BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,8}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(CGSize)dynamicSizeFromText :(NSString *)strText withFont:(UIFont *)font withMaxSize:(CGSize)maxSize
{
    NSDictionary *attributes = @{NSFontAttributeName:font};
    
    CGRect rect = [strText boundingRectWithSize:maxSize
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:attributes
                                        context:nil];
    return rect.size;
}

+(NSMutableArray *) sortingArray:(NSMutableArray *)arrSorted withKey:(NSString *)strKey
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:strKey ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray *arrSortDescriptor = [NSArray arrayWithObject:sortDescriptor];
    
    [arrSorted sortUsingDescriptors:arrSortDescriptor];
    
    return arrSorted;
}

+(UIImage *)fixrotation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+(NSString *)getRoundedMinute:(NSString *)strTime
{
    @try
    {
        NSString *strHour = [[strTime componentsSeparatedByString:@":"] objectAtIndex:0];
        NSString *strMinute = [[strTime componentsSeparatedByString:@":"] objectAtIndex:1];
        
        if ([strMinute intValue] == 0 || [strMinute intValue] == 15 || [strMinute intValue] == 30 || [strMinute intValue] == 45)
        {
            return strTime;
        }
        else if ([strMinute intValue] > 0 && [strMinute intValue] < 15)
        {
            strMinute = @"15";
        }
        else if ([strMinute intValue] > 15 && [strMinute intValue] < 30)
        {
            strMinute = @"30";
        }
        else if ([strMinute intValue] > 30 && [strMinute intValue] < 45)
        {
            strMinute = @"45";
        }
        else if ([strMinute intValue] > 45)
        {
            strMinute = @"00";
            strHour = [NSString stringWithFormat:@"%d",[strHour intValue]+1];
        }
        
        strTime = [NSString stringWithFormat:@"%@:%@",strHour,strMinute];
        
        return strTime;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception:- %@",exception);
    }
    @finally
    {
    }
}

+(NSString*)convertDateToDeviceTime:(NSString*)msgDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    NSDate *date = [dateFormatter dateFromString:msgDate];
    
    NSDateFormatter *dateFormatterDest = [[NSDateFormatter alloc] init];
    [dateFormatterDest setDateFormat:@"dd-MM-yyyy HH:mm"];
    NSDate *dateNew = [NSDate dateWithTimeIntervalSinceNow:date.timeIntervalSinceNow];
    NSString *dateString = [dateFormatterDest stringFromDate:dateNew];
    
    return dateString;
}

- (UIColor *)colorWithHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(NSString *) getNumberFormate :(int)intValue
{
    NSNumberFormatter *num = [[NSNumberFormatter alloc] init];
    [num setNumberStyle: NSNumberFormatterCurrencyStyle];
    [num setCurrencyCode:@""];
    [num setInternationalCurrencySymbol:@""];
    [num setMaximumFractionDigits:0];
    num.positiveFormat = [num.positiveFormat
                          stringByReplacingOccurrencesOfString:@"¤" withString:@""];
    num.negativeFormat = [num.negativeFormat
                          stringByReplacingOccurrencesOfString:@"¤" withString:@""];
    
    NSString *numberAsString = [num stringFromNumber:[NSNumber numberWithInt:intValue]];
    
    return numberAsString;
}

@end

@implementation NSDictionary (JSONKitSerializing)

- (NSString *)JSONString
{
    NSString *jsonString=@"";
    
    @try
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        if (!jsonData)
        {
            NSLog(@"JsonError: %@", error);
        }
        else
        {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"exception: %@", exception);
    }
    @finally
    {
    }
    return jsonString;
}

@end
@implementation NSArray(JSONKitSerializing)

- (NSString *)JSONString{
    
    NSString *jsonString=@"";
    @try {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        if (!jsonData) {
            NSLog(@"JsonError: %@", error);
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception: %@", exception);
    }
    @finally {
        
    }
    return jsonString;
}

@end
