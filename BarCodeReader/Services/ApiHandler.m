//
//  ApiHandler.m
//  BarCodeReader
//
//  Created by Iain Coleman on 10/11/2017.
//  Copyright © 2017 Iain Coleman. All rights reserved.
//

#import "ApiHandler.h"

@implementation ApiHandler

+ (id)sharedManager {
    
    //Sets up singleton
    
    static ApiHandler *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

-(void)getBarcodeData:(NSString*)code {
    
    NSString *firstPartOfUrl = API_URL;
    NSString *barcode = [NSString stringWithFormat:@"%@",code];
    
    NSString *fullUrl = [NSString stringWithFormat:@"%@%@",firstPartOfUrl,barcode];
    NSLog(@"The fullurl is %@",fullUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:fullUrl]];
    
    //Adapted from JSON tutorial here: https://www.youtube.com/watch?v=6Akuy4KZz64
    
    NSURLSessionDataTask *task = [[self getURLSession] dataTaskWithRequest:request completionHandler:^( NSData *data, NSURLResponse *response, NSError *error )
                                  {
                                      dispatch_async( dispatch_get_main_queue(),
                                                     ^{
                                                         
                                                         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                                                         
                                                         NSInteger statusCode = [httpResponse statusCode];
                                                         
                                                         
                                                         if (statusCode == 200) {//success, now parse data
                                                             
                                                             if(data) {
                                                                 // parse returned JSON array
                                                                 NSError *jsonError;
                                                                 NSDictionary *jSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                                                                 
                                                                 NSDictionary *items = jSONDictionary[ITEMS][0];
                                                                 
                                                                 NSMutableString *itemTitle = [NSMutableString new];
                                                                 NSMutableString *itemBrand = [NSMutableString new];
                                                                 NSMutableString *itemUPC = [NSMutableString new];
                                                                 
                                                                 if (items[TITLE] != nil) {
                                                                     [itemTitle appendFormat:@"Title: %@\n", items[TITLE]];
                                                                 } else {
                                                                     [itemTitle appendFormat:@"Title: Not given\n"];
                                                                 }
                                                                 
                                                                 if (items[BRAND] != nil) {
                                                                     [itemBrand appendFormat:@"Brand: %@\n", items[BRAND]];
                                                                 } else {
                                                                     [itemBrand appendFormat:@"Brand: Not given\n"];
                                                                 }
                                                                 
                                                                 if (items[UPC] != nil) {
                                                                     [itemUPC appendFormat:@"UPC: %@\n", items[UPC]];
                                                                 } else {
                                                                     [itemUPC appendFormat:@"UPC: Not given\n"];
                                                                 }
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE_TITLE object:itemTitle userInfo:nil];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE_BRAND object:itemBrand userInfo:nil];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE_UPC object:itemUPC userInfo:nil];

                                                             } else {
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE_TITLE object:@"An error occured" userInfo:nil];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE_BRAND object:@"N/A" userInfo:nil];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE_UPC object:@"N/A" userInfo:nil];
                                                             }
                                                         } else {
                                                             if (data) { //Parse error response
                                                                 NSError *parseError = nil;
                                                                 
                                                                 NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
                                                                 
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE_TITLE object:dictionary[MESSAGE] userInfo:nil];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE_BRAND object:@"N/A" userInfo:nil];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE_UPC object:@"N/A" userInfo:nil];

                                                                 
                                                             } else {
                                                                 NSLog(@"Error %li",(long)statusCode);
                                                                 
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE_TITLE object:@"An error occured" userInfo:nil];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE_BRAND object:@"N/A" userInfo:nil];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE_UPC object:@"N/A" userInfo:nil];
                                                             }
                                                         }
                                                         
                                                     });
                                  }];
    [task resume];
}



- ( NSURLSession * )getURLSession {
    
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once( &onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:configuration];
    });
    
    return session;
}

@end
