//
//  RHLANClient.h
//  RHLANClient
//
//  Created by zhuruhong on 2017/8/21.
//  Copyright © 2017年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncUdpSocket.h>

@interface RHLANClient : NSObject <GCDAsyncUdpSocketDelegate>

@property (nonatomic,   copy) NSString *udpGroup;
@property (nonatomic, assign) NSInteger udpPort;

@property (nonatomic,   copy) NSString *tcpHost;
@property (nonatomic, assign) NSInteger tcpPort;

@property (nonatomic, strong, readonly) dispatch_queue_t socketQueue;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;

- (void)startUdpClient;
- (void)stopUdpClient;

- (void)sendData:(NSData *)data;
- (void)sendData:(NSData *)data toHost:(NSString *)host port:(NSInteger)port;
- (void)sendData:(NSData *)data toHost:(NSString *)host port:(NSInteger)port tag:(long)tag;

- (void)startTcpClient;
- (void)stopTcpClient;

@end
