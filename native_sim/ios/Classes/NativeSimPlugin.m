#import "NativeSimPlugin.h"
#if __has_include(<native_sim/native_sim-Swift.h>)
#import <native_sim/native_sim-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "native_sim-Swift.h"
#endif

@implementation NativeSimPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativeSimPlugin registerWithRegistrar:registrar];
}
@end
