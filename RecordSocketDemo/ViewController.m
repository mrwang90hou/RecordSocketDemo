//
//  ViewController.m
//  RecordSocketDemo
//
//  Created by L on 2018/12/11.
//  Copyright © 2018年 goockr. All rights reserved.
//

#import "ViewController.h"
#import <GCDAsyncSocket.h>
@interface ViewController ()<GCDAsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UITextView *showMessageTF;
// 客户端socket
@property (strong, nonatomic) GCDAsyncSocket *clientSocket;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 1.初始化
    self.clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

// 测试连接
- (IBAction)connectAction:(id)sender {
    // 2.链接服务器
    [self.clientSocket connectToHost:self.addressTF.text onPort:self.portTF.text.integerValue viaInterface:nil withTimeout:-1 error:nil];
}

//开始录制
- (IBAction)beginRecordingAction:(id)sender {
    [self.clientSocket connectToHost:self.addressTF.text onPort:self.portTF.text.integerValue viaInterface:nil withTimeout:-1 error:nil];
    
    NSMutableArray *arrayMsg = [[NSMutableArray alloc]init];
    //    ==msg head id==
    [arrayMsg addObject:@(0x21)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    //    ==msg head ack==
    [arrayMsg addObject:@(0x00)];
    //    ==msg head dir==
    [arrayMsg addObject:@(0x01)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    //    ==cmd_Id==
    [arrayMsg addObject:@(0x07)];
    [arrayMsg addObject:@(0x00)];
    
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x0E)];
    [arrayMsg addObject:@(0x00)];
    //    ==cmd_Datalen==
    [arrayMsg addObject:@(0x01)];
    [arrayMsg addObject:@(0x00)];
    //    ==cmd_DataSum==
    [arrayMsg addObject:@(0x01)];
    [arrayMsg addObject:@(0x00)];
    //    ==cmd_Data==
    [arrayMsg addObject:@(0x01)];
    Byte socketShake[20];
    for (int i = 0; i<[arrayMsg count]; i++) {
        socketShake[i] = (Byte)[[arrayMsg objectAtIndex:i] intValue];
    }
    NSData *shakeData = [NSData dataWithBytes:socketShake length:[arrayMsg count]];
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    [self.clientSocket writeData:shakeData withTimeout:-1 tag:0];
}
//停止录制
- (IBAction)stopRecording:(id)sender {
    [self.clientSocket connectToHost:self.addressTF.text onPort:self.portTF.text.integerValue viaInterface:nil withTimeout:-1 error:nil];
    
    NSMutableArray *arrayMsg = [[NSMutableArray alloc]init];
    //    ==msg head id==
    [arrayMsg addObject:@(0x21)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    //    ==msg head ack==
    [arrayMsg addObject:@(0x00)];
    //    ==msg head dir==
    [arrayMsg addObject:@(0x01)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    //    ==cmd_Id==
    [arrayMsg addObject:@(0x07)];
    [arrayMsg addObject:@(0x00)];
    //    0x00 0x00 0x0E 0x00
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x0E)];
    [arrayMsg addObject:@(0x00)];
    //    ==cmd_Datalen==
    //    0x01 0x00
    [arrayMsg addObject:@(0x01)];
    [arrayMsg addObject:@(0x00)];
    //    ==cmd_DataSum==
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    //    ==cmd_Data==
    [arrayMsg addObject:@(0x00)];
    Byte socketShake[20];
    for (int i = 0; i<[arrayMsg count]; i++) {
        socketShake[i] = (Byte)[[arrayMsg objectAtIndex:i] intValue];
    }
    NSData *shakeData = [NSData dataWithBytes:socketShake length:[arrayMsg count]];
    [self.clientSocket writeData:shakeData withTimeout:-1 tag:0];
}
//拍照
- (IBAction)picAction:(id)sender {
    [self.clientSocket connectToHost:self.addressTF.text onPort:self.portTF.text.integerValue viaInterface:nil withTimeout:-1 error:nil];
    //缓存数组
    NSMutableArray *arrayMsg = [[NSMutableArray alloc]init];
    //    ==msg head id==
    //    NSArray *arr01 = [0x21,0x00,0x00,0x00];
    [arrayMsg addObject:@(0x21)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    //    [arrayMsg addObjectsFromArray:arr01];
    //    ==msg head ack==
    [arrayMsg addObject:@(0x00)];
    //    ==msg head dir==
    [arrayMsg addObject:@(0x01)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    //    ==cmd_Id==
    [arrayMsg addObject:@(0x07)];
    [arrayMsg addObject:@(0x00)];
    //    0x00 0x00 0x0E 0x00
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x00)];
    [arrayMsg addObject:@(0x10)];
    [arrayMsg addObject:@(0x00)];
    //    ==cmd_Datalen==
    //    0x01 0x00
    [arrayMsg addObject:@(0x01)];
    [arrayMsg addObject:@(0x00)];
    //    ==cmd_DataSum==
    [arrayMsg addObject:@(0x01)];
    [arrayMsg addObject:@(0x00)];
    //    ==cmd_Data==
    [arrayMsg addObject:@(0x01)];
    Byte socketShake[20];
    for (int i = 0; i<[arrayMsg count]; i++) {
        socketShake[i] = (Byte)[[arrayMsg objectAtIndex:i] intValue];
    }
    NSData *shakeData = [NSData dataWithBytes:socketShake length:[arrayMsg count]];
    [self.clientSocket writeData:shakeData withTimeout:-1 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self showMessageWithStr:@"链接成功"];
    NSLog(@"链接成功");
    [self showMessageWithStr:[NSString stringWithFormat:@"服务器IP: %@", host]];
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}
// 收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"收到消息");
    NSString *str = [self HexStringWithData:data];
    [self showMessageWithStr:[NSString stringWithFormat:@"收到消息:%@",str]];
    NSLog(@"收到消息：str = %@",str);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// 信息展示
- (void)showMessageWithStr:(NSString *)str {
    self.showMessageTF.text = [self.showMessageTF.text stringByAppendingFormat:@"%@\n", str];
}

// 链接失败
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"链接失败 \t,err = %@,%ld",err.domain,(long)err.code);
}

//data转为十六进制字符串
-(NSString *)HexStringWithData:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else{
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    hexStr = [hexStr uppercaseString];
    return hexStr;
}

@end
