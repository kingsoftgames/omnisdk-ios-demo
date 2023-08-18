# OmniSDK Demo for iOS

The Demo includes code examples illustrating features of the OmniSDK iOS API.

# Prepare

- Add the following configuration to the `Info.plist` file:

| Key           | Type   | Necessity | explanation |
| ------------- | ------ | -------- | -------- |
| OmniSDKAppId  | String | Y        | appid    |
| OmniSDKAppKey | String | Y        | appkey   |
| OmniSDKPlanId | String | Y        | planid |

- Copy your OmniSDK Frameworks to workspace
- Switch to your iOS Provisioning file

# Troubleshooting

## Enable & Sign

`DYLD_INSERT_LIBRARIES=/Developer/usr/lib/libBacktraceRecording.dylib:/Developer/usr/lib/libMainThreadChecker.dylib:/Developer/Library/PrivateFrameworks/DTDDISupport.framework/libViewDebuggerSupport.dylib`

**Solution**

Targets -> General -> Frameworks, Libraries, and Embedded Content

`Enable & Sign` your OmniSDK Frameworks
