//
//  ViewController.m
//  BarCodeReader
//
//  Created by Iain Coleman on 10/11/2017.
//  Copyright © 2017 Iain Coleman. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *manualEntryTextField;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UITextView *resultsTextView;

@end


@implementation ViewController

@synthesize manualEntryTextField;
@synthesize goButton;
@synthesize scanButton;
@synthesize warningLabel;
@synthesize resultsTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Add rounded edges to buttons
    goButton.layer.cornerRadius = 20;
    goButton.layer.masksToBounds = YES;
    scanButton.layer.cornerRadius = 20;
    scanButton.layer.masksToBounds = YES;
    
    
    //Set text field as UITextFieldDelegate
    manualEntryTextField.delegate = self;
    
    //Hide both the warning label and the go button
    goButton.hidden = YES;
    warningLabel.hidden = YES;

    //Add a Done button to the numeric keypad to dismiss it
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(donePressed:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    manualEntryTextField.inputAccessoryView = keyboardDoneButtonView;
    
    //Set up observer for the returned data from ApiHandler
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTextField:) name:BARCODE_RESPONSE object:nil];
    
}



-(void)textFieldDidBeginEditing:(UITextField *)manualEntryTextField {
    //Changes Go button to 13 digit warning
    warningLabel.hidden = NO;
    goButton.hidden = YES;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    //Show the Go button and hide the warning label
    goButton.hidden = NO;
    warningLabel.hidden = YES;
    return YES;
}



-(void)dismissNumberPad{
    
    [manualEntryTextField resignFirstResponder];
    
}

-(IBAction)donePressed:(id)sender {
    if ([self checkBarcodeIsComplete]) {
        goButton.hidden = NO;
        warningLabel.hidden = YES;
        [self dismissNumberPad];

    } else {
        NSLog(@"Not a valid barcode");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please check!" message:@"Barcodes must be 13 digits long." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        goButton.enabled = NO;
    }
}

-(BOOL)checkBarcodeIsComplete {
    
    //Checks to see that barcode is a 13 digit integer
    NSString * barcode = manualEntryTextField.text;
    if((manualEntryTextField.text.length == 13) && ([barcode rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location)) {
        NSLog(@"13 digit integer is present");
        return true;
    } else {
        return false;
    }
}



-(void)updateTextField:(NSNotification*)note {
    resultsTextView.text = (NSString*)note.object;
}



-(IBAction)goToScannerVC {
    [self performSegueWithIdentifier:@"toScannerVC" sender:nil];
}



- (IBAction)goButtonPressed:(id)sender {
    
    //Check for 13 digit integer - if present, go to ResultsVC
    
    if ([self checkBarcodeIsComplete]) {
        NSLog(@"Go button pressed & 13 digit integer present!");
        [[ApiHandler sharedManager] getBarcodeData:(self.manualEntryTextField.text)];
    } else {
        
    // This alert box will only show if the user removes characters from a 13 digit code
        NSLog(@"Not 13 digits");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please check!" message:@"Barcodes must be 13 digits long." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }

}

@end
