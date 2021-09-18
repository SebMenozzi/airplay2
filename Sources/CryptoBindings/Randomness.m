#import "Randomness.h"

@implementation Randomness

+(NSData*) generateRandomBytes:(int)numberBytes {
    /* used to generate db master key, and to generate signaling key, both at install */
    NSMutableData* randomBytes = [NSMutableData dataWithLength:numberBytes];
    int err = 0;
    err = SecRandomCopyBytes(kSecRandomDefault,numberBytes,[randomBytes mutableBytes]);
    if(err != noErr && [randomBytes length] != numberBytes) {
        @throw [NSException exceptionWithName:@"random problem" reason:@"problem generating the random " userInfo:nil];
    }
    return [NSData dataWithData:randomBytes];
}

@end
