//
//  YSNViewController.h
//  YSNBluetoothChat
//
//  Created by Takahashi Yosuke on 2014/02/09.
//  Copyright (c) 2014年 Yosan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface YSNViewController : UIViewController <MCBrowserViewControllerDelegate, MCSessionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *displayNameField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UISwitch *advertiseSwitch;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
- (IBAction)onSearchButtonClicked:(id)sender;
- (IBAction)onAdvertiseSwitchChanged:(id)sender;
- (IBAction)onDisconnectButtonClicked:(id)sender;
- (IBAction)onSendButtonCliced:(id)sender;

@end
