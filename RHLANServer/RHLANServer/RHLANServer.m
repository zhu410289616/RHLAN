//
//  RHLANServer.m
//  RHLANServer
//
//  Created by zhuruhong on 2017/8/21.
//  Copyright © 2017年 zhuruhong. All rights reserved.
//

#import "RHLANServer.h"

@implementation RHLANServer

- (instancetype)init
{
    if (self = [super init]) {
        _udpGroup = @"232.1.0.2";
        _udpPort = 22345;
        _tcpHost = @"192.168.1.1";
        _tcpPort = 1708;
        _socketQueue = dispatch_queue_create("socketQueue", NULL);
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        _connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (void)start
{
    [self startUdpServer];
    [self startTcpServer];
}

- (void)stop
{
    [self stopUdpServer];
    [self stopTcpServer];
}

- (void)startUdpServer
{
    NSError *error = nil;
    if (![_udpSocket bindToPort:_udpPort error:&error]) {
        NSLog(@"Error starting udp echo server (bind): %@", error);
        return;
    }
    
    if (![_udpSocket enableBroadcast:YES error:&error]) {
        NSLog(@"Error enableBroadcast: %@", error);
        return;
    }
    
    if (![_udpSocket joinMulticastGroup:_udpGroup error:&error]) {
        NSLog(@"Error joinMulticastGroup[%@]: %@", _udpGroup, error);
        return;
    }
    
    if (![_udpSocket beginReceiving:&error]) {
        [_udpSocket close];
        NSLog(@"Error starting server (recv): %@", error);
        return;
    }
    
    NSLog(@"Udp echo server started on port %hu", [_udpSocket localPort]);
}

- (void)stopUdpServer
{
    [_udpSocket pauseReceiving];
}

- (void)startTcpServer
{
    NSError *error = nil;
    if (![_tcpSocket acceptOnPort:_tcpPort error:&error]) {
        NSLog(@"Error starting tcp echo server: %@", error);
        return;
    }
    
    NSLog(@"Tcp echo server started on %@:%hu", [_tcpSocket localHost], [_tcpSocket localPort]);
}

- (void)stopTcpServer
{}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSLog(@"udpSocket didReceiveData: [%@] - %@", address, data);
    
    // send current ip to client
    NSString *msg = [NSString stringWithFormat:@"%ld", _tcpPort];
    NSData *msData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [sock sendData:msData toAddress:address withTimeout:-1 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    @synchronized(_connectedSockets) {
        [_connectedSockets addObject:newSocket];
        newSocket.delegate = self;
        [newSocket readDataWithTimeout:-1 tag:0];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    @synchronized (_connectedSockets) {
        [_connectedSockets removeObject:sock];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *host = [sock connectedHost];
    UInt16 port = [sock connectedPort];
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[%@:%hu] didReadData length: %lu, msg: %@", host, port, (unsigned long)data.length, msg);
    // Echo message back to client
    [sock writeData:data withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSString *host = [sock connectedHost];
    UInt16 port = [sock connectedPort];
    NSLog(@"[%@:%hu] didWriteDataWithTag: %ld", host, port, tag);
    [sock readDataWithTimeout:-1 tag:tag];
}

@end
