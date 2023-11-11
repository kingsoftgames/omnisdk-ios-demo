# OmniSDK Demo for iOS

The Demo includes code examples illustrating features of the OmniSDK iOS API v3.

Please refer to [the iOS Integration Guide Of v3](https://docs.seayoo.com/sdk/getting-started/ios/quick-start/api/v3/) in the Kingsoft Seayoo Documentation Center.


# Prepare

- Add the following configuration to the `Info.plist` file:

| Key           | Type   | Necessity | explanation |
| ------------- | ------ | -------- | -------- |
| OmniSDKAppId  | String | Y        | appid    |
| OmniSDKAppKey | String | Y        | appkey   |
| OmniSDKPlanId | String | Y        | planid |
| OmniSDKChannel| String | Y        | ChannelName |

- Copy your OmniSDK Frameworks to workspace
- Switch to your iOS Provisioning file

# History
[v3.0](https://github.com/kingsoftgames/omnisdk-ios-demo/releases/tag/v3.0.0)

[v2.7](https://github.com/kingsoftgames/omnisdk-ios-demo/releases/tag/v2.7)

[v2.6](https://github.com/kingsoftgames/omnisdk-ios-demo/releases/tag/v2.6)

[v2.0](https://github.com/kingsoftgames/omnisdk-ios-demo/releases/tag/v2.0)

# Troubleshooting

## Enable & Sign

`DYLD_INSERT_LIBRARIES=/Developer/usr/lib/libBacktraceRecording.dylib:/Developer/usr/lib/libMainThreadChecker.dylib:/Developer/Library/PrivateFrameworks/DTDDISupport.framework/libViewDebuggerSupport.dylib`

**Solution**

Targets -> General -> Frameworks, Libraries, and Embedded Content

`Enable & Sign` your OmniSDK Frameworks
