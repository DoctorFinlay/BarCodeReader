//
//  ViewController.h
//  BarCodeReader
//
//  Created by Iain Coleman on 10/11/2017.
//  Copyright © 2017 Iain Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApiHandler.h"

@interface ViewController : UIViewController <UITextFieldDelegate>

//Scanner image is taken from Pixabay and is licensed CC0

-(BOOL)checkBarcodeIsComplete;

@end

