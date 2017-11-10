//
//  ScannerVC.m
//  BarCodeReader
//
//  Created by Iain Coleman on 10/11/2017.
//  Copyright © 2017 Iain Coleman. All rights reserved.
//

#import "ScannerVC.h"

@interface ScannerVC ()
{
AVCaptureSession *captureSession;
AVCaptureVideoPreviewLayer *captureLayer;
IBOutlet UIView *cameraPreviewView;
}
@end

@implementation ScannerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Adapted from code found on StackOverflow - why reinvent the wheel?!
    
    captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    
    if (!error) {
        [captureSession addInput:input];
        
        AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        
        [captureSession addOutput:captureMetadataOutput];
        
        // Create a new queue and set delegate for metadata objects scanned.
        dispatch_queue_t dispatchQueue;
        
        dispatchQueue = dispatch_queue_create("scan_queue", NULL);
        
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        
        
        
        [captureMetadataOutput setMetadataObjectTypes:[captureMetadataOutput availableMetadataObjectTypes]];
        
        
        captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
        [captureLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [captureLayer setFrame:cameraPreviewView.layer.bounds];
        [cameraPreviewView.layer addSublayer:captureLayer];
        
        
        
        
    } else {
        NSLog(@"Error Ocurred: %@", error.localizedDescription );
    }
    
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![captureSession isRunning]) {
        [captureSession startRunning];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([captureSession isRunning]) {
        [captureSession stopRunning];
    }
}
    

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    // Do your action on barcode capture here:
    NSString *capturedBarcode = nil;
    
    //Valid types of barcode
    NSArray *supportedBarcodeTypes = @[AVMetadataObjectTypeUPCECode,
                                       AVMetadataObjectTypeCode39Code,
                                       AVMetadataObjectTypeCode39Mod43Code,
                                       AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeCode93Code,
                                       AVMetadataObjectTypeCode128Code,
                                       AVMetadataObjectTypePDF417Code,
                                       AVMetadataObjectTypeQRCode,
                                       AVMetadataObjectTypeAztecCode];
    
    
    
    for (AVMetadataObject *barcodeMetadata in metadataObjects) {
        
        for (NSString *supportedBarcode in supportedBarcodeTypes) {
            
            if ([supportedBarcode isEqualToString:barcodeMetadata.type]) {
                
                // This is a supported barcode
                
                AVMetadataMachineReadableCodeObject *barcodeObject = (AVMetadataMachineReadableCodeObject *)[captureLayer transformedMetadataObjectForMetadataObject:barcodeMetadata];
                capturedBarcode = [barcodeObject stringValue];
                NSLog(@"captured BC = %@", capturedBarcode);
                //barcode read and validated, stop scan and fire delegate method
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [captureSession stopRunning];
                    [[ApiHandler sharedManager] getBarcodeData:capturedBarcode];
                    [self dismissViewControllerAnimated:true completion:nil];
                });
                return;
            }
        }
    }
}


-(IBAction)goBack {
    [self dismissViewControllerAnimated:true completion:nil];
}




@end
