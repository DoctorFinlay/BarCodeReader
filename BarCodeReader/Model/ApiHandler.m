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
                                                                 
                                                                 NSMutableString *itemString = [NSMutableString new];
                                                                 
                                                                 if (items[TITLE] != nil) {
                                                                     [itemString appendFormat:@"Title: %@\n", items[TITLE]];
                                                                 } else {
                                                                     [itemString appendFormat:@"Title: Not given\n"];
                                                                 }
                                                                 
                                                                 if (items[BRAND] != nil) {
                                                                     [itemString appendFormat:@"Brand: %@\n", items[BRAND]];
                                                                 } else {
                                                                     [itemString appendFormat:@"Brand: Not given\n"];
                                                                 }
                                                                 
                                                                 if (items[UPC] != nil) {
                                                                     [itemString appendFormat:@"UPC: %@\n", items[UPC]];
                                                                 } else {
                                                                     [itemString appendFormat:@"UPC: Not given\n"];
                                                                 }
                                                                 NSLog(@"Item String: %@", itemString);
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE object:itemString userInfo:nil];
                                                             } else {
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE object:@"An error occured" userInfo:nil];
                                                             }
                                                         } else {
                                                             if (data) { //Parse error response
                                                                 NSError *parseError = nil;
                                                                 
                                                                 NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
                                                                 
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE object:dictionary[MESSAGE] userInfo:nil];
                                                             } else {
                                                                 NSLog(@"Error %li",(long)statusCode);
                                                                 
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:BARCODE_RESPONSE object:@"An error occured" userInfo:nil];
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
