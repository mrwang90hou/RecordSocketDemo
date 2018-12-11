//
//  AppDelegate.m
//  RecordSocketDemo
//
//  Created by L on 2018/12/11.
//  Copyright © 2018年 goockr. All rights reserved.
//

#import "AppDelegate.h"
#import "KalayVpnAPIs.h"
@interface AppDelegate ()

@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)UIBackgroundTaskIdentifier bgTask;
@end

@implementation AppDelegate
@synthesize window = _window;
#define CHECK_KVPN_ERR(func, ret) \
{ \
ret = func; \
if (ret < 0) { \
NSLog(@"%s failed!, error code: %d \n", #func, ret); \
goto ERR; \
} \
}

#define DEFAULT_MAX_CONNECTIONS            32
#define DEFAULT_TUNNEL_BUF_SIZE            128 * 1024            // 128KB

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    #pragma mark -启动KalayVpnService
        [self performSelectorInBackground:@selector(StartKalayVpnService) withObject:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(logAgain:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    UIApplication* app = [UIApplication sharedApplication];
    self.bgTask = UIBackgroundTaskInvalid;
    __weak __typeof (&*self)weakSelf = self;
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.bgTask != UIBackgroundTaskInvalid) {
                weakSelf.bgTask = UIBackgroundTaskInvalid;
            }
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (weakSelf.bgTask != UIBackgroundTaskInvalid) {
                weakSelf.bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
}

- (void)logAgain:(NSTimer*)timer{
    //无限后台
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

const char *UID = "C1YU9X5WKV7M1H6GUHX1";

static int getConnInfo(int KSID) {
    int rc = KVPN_ER_NoERROR;
    KVConnInfo info;
    char *ConnMode[] = {"LAN", "P2P", "UDP_RLY", "TCP_RLY"};
    
    memset(&info, 0, sizeof(KVConnInfo));
    rc = KalayVPN_GetConnInfo(KSID, &info);
    
    if(rc == KVPN_ER_NoERROR) {
        NSLog(@"\n=============== KVConnInfo ===============\n");
        NSLog(@"# Connection Mode : %s\n", ConnMode[info.ConnMode]);
        NSLog(@"# TryP2PTimeout   : %d\n", info.TryP2PTimeout);
        NSLog(@"# LocalNatType    : %d\n", info.LocalNatType);
        NSLog(@"# RemoteNatType   : %d\n", info.RemoteNatType);
        NSLog(@"# RemoteVersion   : %s\n", info.RemoteVersion);
        NSLog(@"# RemoteIP : %s, RemotePort : %d\n", info.RemoteIP, info.RemotePort);
        NSLog(@"=============== KVConnInfo ===============\n");
    }
    
    return rc;
}

static int MappingService_WEB(KVManager manager) {
    return KalayVPN_PortMapping_Service(KV_SERVICE_TCP, manager, 10080, 80);
}

static int MappingService_FTP(KVManager manager) {
    return KalayVPN_PortMapping_Service(KV_SERVICE_FTP, manager, 10001, 21);
}

static int MappingService_SSH(KVManager manager) {
    return KalayVPN_PortMapping_Service(KV_SERVICE_TCP, manager, 10002, 22);
}

static int MappingService_TELNET(KVManager manager) {
    return KalayVPN_PortMapping_Service(KV_SERVICE_TCP, manager, 10003, 23);
}

static int MappingService_RTSP(KVManager manager) {
    //    return KalayVPN_PortMapping_Service(KV_SERVICE_RTSP, manager, 10004, 8554);
    return KalayVPN_PortMapping_Service(KV_SERVICE_RTSP, manager, 10554, 554);
    
}

void StartKalayVpnService_Internal(const char* UID)
{
    int rc = KVPN_ER_NoERROR;
    int KSID = -1;
    KVManager manager = NULL;
    const char* account = "kalayvpn_user";
    const char* password = "1234567890";
    NSLog(@"KalayVPN version : %s\n", KalayVPN_GetVersion());
    CHECK_KVPN_ERR(KalayVPN_Initialize(DEFAULT_MAX_CONNECTIONS), rc)
    CHECK_KVPN_ERR(KalayVPN_Connect(UID, account, password), KSID)
    CHECK_KVPN_ERR(KalayVPN_GetManager(KSID, &manager), rc)
    // Config KalayVPN internal parameter here if need.
    CHECK_KVPN_ERR(KalayVPN_SetConfigOpt(KV_CONFIG_TUNNEL_BUF_SIZE, manager, DEFAULT_TUNNEL_BUF_SIZE), rc)
    
    // Get Connection Info
    CHECK_KVPN_ERR(getConnInfo(KSID), rc)
    if(rc == KVPN_ER_NoERROR) {
        NSLog(@"Connected to KalayVpnService\n");
        // Port Mapping
        CHECK_KVPN_ERR(MappingService_WEB(manager), rc)
        CHECK_KVPN_ERR(MappingService_FTP(manager), rc)
        CHECK_KVPN_ERR(MappingService_SSH(manager), rc)
        CHECK_KVPN_ERR(MappingService_TELNET(manager), rc)
        CHECK_KVPN_ERR(MappingService_RTSP(manager), rc)
        // If isDetach = false, KalayVPN_StartService is a blocking call.
        // It's used in client side.
        // When KalayVPN_StartService finish tasks or get errors, it will break from KalayVPN_StartService().
        int isDetach = false;
        CHECK_KVPN_ERR(KalayVPN_StartService(manager, isDetach), rc)
    }
ERR:
    NSLog(@"KalayVPN is deinitialized!\n");
    KalayVPN_DeInitialize();
    return;
}

- (void) StartKalayVpnService
{
    NSLog(@"StartKalayVpnService Start");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    while(true) {
        StartKalayVpnService_Internal(UID);
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSLog(@"StartKalayVpnService Stop");
    
    return;
}

- (void) StopKalayVpnService
{
    NSLog(@"StopKalayVpnService Start");
    
    KalayVPN_DeInitialize();
    
    NSLog(@"StopKalayVpnService End");
}


@end
