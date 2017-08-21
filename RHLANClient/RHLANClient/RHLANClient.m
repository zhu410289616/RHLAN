//
//  RHLANClient.m
//  RHLANClient
//
//  Created by zhuruhong on 2017/8/21.
//  Copyright © 2017年 zhuruhong. All rights reserved.
//

#import "RHLANClient.h"
#import <RHSocketDelimiterEncoder.h>
#import <RHSocketDelimiterDecoder.h>
#import <RHSocketService.h>

@implementation RHLANClient

- (instancetype)init
{
    if (self = [super init]) {
        _udpGroup = @"232.1.0.2";
        _udpPort = 22345;
        _tcpHost = @"192.168.1.1";
        _tcpPort = 55667;
        _socketQueue = dispatch_queue_create("socketQueue", NULL);
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
    }
    return self;
}

- (void)startUdpClient
{
    NSError *error = nil;
    if (![_udpSocket bindToPort:0 error:&error]) {
        NSLog(@"Error binding: %@", error);
        return;
    }
    
    if (![_udpSocket enableBroadcast:YES error:&error]) {
        NSLog(@"Error enableBroadcast: %@", error);
        return;
    }
    
    if (![_udpSocket beginReceiving:&error]) {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    NSLog(@"startUdpClient Ready");
}

- (void)sendData:(NSData *)data
{
    if (data.length == 0) {
        return;
    }
    
    [self sendData:data toHost:_udpGroup port:_udpPort];
}

- (void)sendData:(NSData *)data toHost:(NSString *)host port:(NSInteger)port
{
    long tag = clock();
    [self sendData:data toHost:host port:port tag:tag];
}

- (void)sendData:(NSData *)data toHost:(NSString *)host port:(NSInteger)port tag:(long)tag
{
    [_udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:tag];
}

- (void)stopUdpClient
{
    [_udpSocket pauseReceiving];
}

- (void)startTcpClient
{}

- (void)stopTcpClient
{}

#pragma mark - GCDAsyncUdpSocketDelegate

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // You could add checks here
    NSLog(@"didSendDataWithTag[%ld]", tag);
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    // You could add checks here
    NSLog(@"didNotSendDataWithTag[%ld]: %@", tag, error);
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *host = [GCDAsyncUdpSocket hostFromAddress:address];
    NSString *port = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"address: %@", host);
    NSLog(@"RECV: %@", port);
    
    RHSocketDelimiterDecoder *decoder = [[RHSocketDelimiterDecoder alloc] init];
    decoder.delimiterData = [@"0" dataUsingEncoding:NSUTF8StringEncoding];
    
    RHSocketDelimiterEncoder *encoder = [[RHSocketDelimiterEncoder alloc] init];
    encoder.delimiterData = [@"0" dataUsingEncoding:NSUTF8StringEncoding];
    
    [RHSocketService sharedInstance].decoder = decoder;
    [RHSocketService sharedInstance].encoder = encoder;
    
    RHSocketPacketRequest *heartbeat = [[RHSocketPacketRequest alloc] init];
    heartbeat.object = @"heartbeat";
    [RHSocketService sharedInstance].heartbeat = heartbeat;
    
    RHSocketConnectParam *connectParam = [[RHSocketConnectParam alloc] init];
    connectParam.host = host;
    connectParam.port = [port intValue];
    [[RHSocketService sharedInstance] startServiceWithConnectParam:connectParam];
}

@end
