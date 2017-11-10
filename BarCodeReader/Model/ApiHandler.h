//
//  ApiHandler.h
//  BarCodeReader
//
//  Created by Iain Coleman on 10/11/2017.
//  Copyright © 2017 Iain Coleman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface ApiHandler : NSObject

+(id)sharedManager;
-(void)getBarcodeData:(NSString*)code;

@end
