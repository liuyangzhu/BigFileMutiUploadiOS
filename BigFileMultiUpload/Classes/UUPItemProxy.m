//
//  UUPItemProxy.m
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/29.
//

#import "UUPItemProxy.h"
@interface UUPItemProxy()
@property (weak, nonatomic) id target;
@end
@implementation UUPItemProxy
+ (instancetype)proxyWithTarget:(id)target {
    UUPItemProxy *proxy = [UUPItemProxy alloc];
    proxy.target = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}
@end
