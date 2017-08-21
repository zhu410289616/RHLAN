//
//  RHLANServer.h
//  RHLANServer
//
//  Created by zhuruhong on 2017/8/21.
//  Copyright © 2017年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncUdpSocket.h>
#import <GCDAsyncSocket.h>

@interface RHLANServer : NSObject <GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate>

@property (nonatomic,   copy) NSString *udpGroup;
@property (nonatomic, assign) NSInteger udpPort;

@property (nonatomic,   copy) NSString *tcpHost;
@property (nonatomic, assign) NSInteger tcpPort;

@property (nonatomic, strong, readonly) dispatch_queue_t socketQueue;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) GCDAsyncSocket *tcpSocket;
@property (nonatomic, strong, readonly) NSMutableArray *connectedSockets;

- (void)start;
- (void)stop;

- (void)startUdpServer;
- (void)stopUdpServer;

- (void)startTcpServer;
- (void)stopTcpServer;

@end
