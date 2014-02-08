//
//  YSNViewController.m
//  YSNBluetoothChat
//
//  Created by Takahashi Yosuke on 2014/02/09.
//  Copyright (c) 2014年 Yosan. All rights reserved.
//

#import "YSNViewController.h"

@interface YSNViewController ()

@end

@implementation YSNViewController
{
    MCSession *_session;
    MCBrowserViewController *_browser;
    MCAdvertiserAssistant *_assistant;
}

typedef enum {
    YSNBluethoothChatModeDisconnected,
    YSNBluethoothChatModeConnected
} YSNBluethoothChatMode;

NSString* const YSNServiceName = @"ysnbtchat";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self p_reloadViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self p_showChatMessage:message by:peerID.displayName];
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    [self p_reloadViews];
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
}

#pragma mark - MCBrowserViewControllerDelegate

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [_browser dismissViewControllerAnimated:YES completion:nil];
    [self p_reloadViews];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [_browser dismissViewControllerAnimated:YES completion:nil];
    [self p_reloadViews];
}

#pragma mark - UI Event

- (IBAction)onSearchButtonClicked:(id)sender
{
    NSString *displayName = _displayNameField.text;
    if (![displayName isEqualToString:@""])
    {
        _session = [self p_createSessionWithDisplayName:displayName];
        _browser = [[MCBrowserViewController alloc] initWithServiceType:YSNServiceName session:_session];
        _browser.delegate = self;
        [self presentViewController:_browser animated:YES completion:nil];
    }
    else
    {
        [self p_showAlertMessageWithTitle:@"Please input display name!"];
    }
}

- (IBAction)onAdvertiseSwitchChanged:(id)sender
{
    UISwitch *startAdvertiseSwitch = (UISwitch *)sender;
    if (startAdvertiseSwitch.isOn)
    {
        NSString *displayName = _displayNameField.text;
        if (![displayName isEqualToString:@""])
        {
            _session = [self p_createSessionWithDisplayName:displayName];
            _assistant = [[MCAdvertiserAssistant alloc] initWithServiceType:YSNServiceName discoveryInfo:nil session:_session];
            [_assistant start];
        }
        else
        {
            [self p_showAlertMessageWithTitle:@"Please input display name!"];
            startAdvertiseSwitch.on = NO;
        }
    }
    else if (_assistant != nil)
    {
        [_assistant stop];
    }
}

- (IBAction)onDisconnectButtonClicked:(id)sender
{
    if (_session != nil)
    {
        [_session disconnect];
    }
}

- (IBAction)onSendButtonCliced:(id)sender
{
    NSString *message = _messageField.text;
    
    if (![message isEqualToString:@""])
    {
        [self p_showChatMessage:message by:_session.myPeerID.displayName];
        NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *peers = [_session connectedPeers];
        NSError *error = nil;
        [_session sendData:messageData toPeers:peers withMode:MCSessionSendDataReliable error:&error];
        _messageField.text = @"";
    }
}

#pragma mark - Private Methods

- (MCSession *)p_createSessionWithDisplayName:(NSString *)displayName
{
    MCPeerID *peerId = [[MCPeerID alloc] initWithDisplayName:displayName];
    MCSession *session = [[MCSession alloc] initWithPeer:peerId];
    session.delegate = self;
    return session;
}

- (void)p_showChatMessage:(NSString *)message by:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        _chatTextView.text = [NSString stringWithFormat:@"%@: %@\n%@", displayName, message, _chatTextView.text];
    });
}

- (void)p_reloadViews
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        BOOL isConnected = ([self p_mode] == YSNBluethoothChatModeConnected);
        if (isConnected)
        {
            _advertiseSwitch.on = false;
            [_assistant stop];
        }
        _displayNameField.enabled = !isConnected;
        _searchButton.enabled = !isConnected;
        _advertiseSwitch.enabled = !isConnected;
        _disconnectButton.enabled = isConnected;
        _messageField.enabled = isConnected;
        _sendButton.enabled = isConnected;
    });
}

- (YSNBluethoothChatMode)p_mode
{
    if (_session != nil && _session.connectedPeers.count > 0)
    {
        return YSNBluethoothChatModeConnected;
    }
    else
    {
        return YSNBluethoothChatModeDisconnected;
    }
}

- (void)p_showAlertMessageWithTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
