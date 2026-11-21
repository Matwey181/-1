# Player iOS build result

Source commit: `2f2f6afaafd7301cf9d75bc883a5b5bafb9a25b2`
Workflow run: https://github.com/Matwey181/-1/actions/runs/44929782501
Result: SUCCESS - IPA created

## Compiler errors (if any)
```
No compiler errors recorded
```

## Final build output
```
    cd /Users/runner/work/-1/-1
    builtin-swiftStdLibTool --copy --verbose --scan-executable /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app/Player --scan-folder /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app/Frameworks --scan-folder /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app/PlugIns --scan-folder /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app/SystemExtensions --scan-folder /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app/Extensions --platform iphoneos --toolchain /Applications/Xcode_16.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain --destination /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app/Frameworks --strip-bitcode --strip-bitcode-tool /Applications/Xcode_16.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/bitcode_strip --emit-dependency-info /Users/runner/work/-1/-1/build/Build/Intermediates.noindex/Player.build/Release-iphoneos/Player.build/SwiftStdLibToolInputDependencies.dep --filter-for-swift-os
Ignoring --strip-bitcode because --sign was not passed

AppIntentsSSUTraining (in target 'Player' from project 'Player')
    cd /Users/runner/work/-1/-1
    /Applications/Xcode_16.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/appintentsnltrainingprocessor --infoplist-path /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app/Info.plist --temp-dir-path /Users/runner/work/-1/-1/build/Build/Intermediates.noindex/Player.build/Release-iphoneos/Player.build/ssu --bundle-id com.matwey181.demoPlayer --product-path /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app --extracted-metadata-path /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app/Metadata.appintents --metadata-file-list /Users/runner/work/-1/-1/build/Build/Intermediates.noindex/Player.build/Release-iphoneos/Player.build/Player.DependencyMetadataFileList --archive-ssu-assets
2026-11-21 17:24:11.221 appintentsnltrainingprocessor[2105:9645] Parsing options for appintentsnltrainingprocessor
2026-11-21 17:24:11.222 appintentsnltrainingprocessor[2105:9645] No AppShortcuts found - Skipping.

RegisterExecutionPolicyException /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app (in target 'Player' from project 'Player')
    cd /Users/runner/work/-1/-1
    builtin-RegisterExecutionPolicyException /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app

Validate /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app (in target 'Player' from project 'Player')
    cd /Users/runner/work/-1/-1
    builtin-validationUtility /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app -infoplist-subpath Info.plist

Touch /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app (in target 'Player' from project 'Player')
    cd /Users/runner/work/-1/-1
    /usr/bin/touch -c /Users/runner/work/-1/-1/build/Build/Products/Release-iphoneos/Player.app

note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in target 'Player' from project 'Player')
** BUILD SUCCEEDED **

```
