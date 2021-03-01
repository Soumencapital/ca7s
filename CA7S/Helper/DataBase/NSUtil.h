//
//  NSUtil.h
//  Anoopam Mission
//
//  Created by Darshit Zalavadiya on 10/11/16.
//  Copyright © 2016 Darshit Zalavadiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

/*!
@class NSUtil

@brief The NSUtil class

@discussion This class is useful for generating jsonstring from NSDictionary and NSArray. Download image from server and storing it to document directory. Converting date format.

@superclass SuperClass: NSObject
*/
@interface NSUtil : NSObject

+(NSString*)getJsonStringFromDictionary:(NSDictionary*)dictionary;
+(void)getImageForView:(UIImageView*)imageView fromURL:(NSString *)imgUrl alterText:(NSString*)alterText;
+(void)getImageForView:(UIImageView *)imageView withYoutubeVideoId:(NSString *)videoID;
+(UIImage *)generateThumbImage : (NSURL *)filepath;
+(void)cropImage:(UIImage *)originalImage forView:(UIImageView *)imageView;
+(UIImage*)getImageFromURL:(NSString *)imgUrl;
+(NSArray*)shortDirectoryArray:(NSArray*)arrayToShort ByKey:(NSString*)key;
+(NSString*)convertDate:(NSString*)dateToConver;
+(NSString*)convertDateTimeStamp:(NSString*)timestamp DateFormat:(NSString*)dateFormat;
+(NSString*)convertDate:(NSString*)dateToConver dateFormate:(NSString*)dateFormate dateFormateToConvert:(NSString*)dateFormateToConvert;
+(NSString*)getDataFromURL:(NSString *)imgUrl;
+ (UIImage *) cropImage:(UIImage *)originalImage;
+(UIImage*)cropImageFromMiddle:(UIImage *)originalImage;
+(void)getImageForView1:(UIView*)imageView fromURL:(NSString *)imgUrl alterText:(NSString*)alterText;
+(UIButton *)setBorderRadius:(id)view;
+(BOOL)validateEmailWithString:(NSString*)email;
+(void)storeImageToDocumentDirectry :(NSString *)imgURL;
+(CATransition *)pushViewFromLeft:(UITableView*)newView;
+(CATransition *)pushViewFromTop:(UITableView*)newView;
+(CATransition *)pushViewFromright:(UITableView*)newView;
+(CATransition *)pushViewFromBottom:(UITableView*)newView;
+ (NSURL *)getPath:(NSString *)path;
/*!
 @brief This method stands for set frame for UIActivityIndicatorView object as per device model.
 
 @return Its return object of UIActivityIndicatorView.
 */
+(UIActivityIndicatorView *)setSpinner :(UIActivityIndicatorView *)spinner;

/*!
 @brief This method stands for add padding in UITextField.
 
 @return Its return object of UITextField.
 */
+(UITextField *) addPaddingOnTextField :(UITextField *)txtField;

/*!
 @brief This method stands set color of placeholder text in UITextField.
 
 @return Its return object of UITextField.
 */
+(UITextField *) setPlaceHolderColorOnTextField :(UITextField *)txtField;

/*!
 @brief This method stands set color of placeholder text in UITextField.
 
 @param  strText The input value representing text for calculating width and height.
 @param  font The input value representing font size and font file for text.
 @param  maxSize The input value representing maximum width or height of text.
 
 @return Its return size of text in width and height.
 */
+(CGSize) dynamicSizeFromText :(NSString *)strText withFont:(UIFont *)font withMaxSize:(CGSize)maxSize;

/*!
 @brief This method stands for sorting of array with key.
 
 @param  arrSorted The input value representing array which are sorting.
 @param  strKey The input value representing key(name, date etc) which we want use for sorting.
 
 @return Its return sorted array.
 */
+(NSMutableArray *) sortingArray:(NSMutableArray *)arrSorted withKey:(NSString *)strKey;

/*!
 @brief This method give time in 15 minute interval.
 
 @param  strTime The input value representing time.
 
 @return Its return time in 15 min interval.
 */
+(NSString *) getRoundedMinute:(NSString *)strTime;

/*!
 @brief This method give UTC date and time.
 
 @param  msgDate The input value representing date and time coming from server which we are converting in UTC.
 
 @return Its return UTC date and time.
 */
+(NSString*)convertDateToDeviceTime:(NSString*)msgDate;

/*!
 @brief This method gives UIColor from a hexadecimal string.
 
 @param  hex The input value representing a hexadecimal string.
 
 @return Its return UIColor.
 */
-(UIColor*)colorWithHexString:(NSString*)hex;

/*!
 @brief This method gives number formate form integer value.
 
 @param  intValue The input value representing integer.
 
 @return Its return number formated string.
 */
+(NSString *) getNumberFormate :(int)intValue;

/*!
 @brief This method stands for rotating image as per its width and height.
 
 @return Its return UIImage.
 */
+(UIImage *)fixrotation:(UIImage *)image;

@end

@interface NSDictionary (JSONKitSerializing)
- (NSString *)JSONString;

@end

@interface NSArray (JSONKitSerializing)
- (NSString *)JSONString;
@end
