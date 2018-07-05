
# Note

This project base on [iOS objective-C codegen project](https://github.com/strongloop-community/loopback-sdk-ios-codegen)

# LoopBack iOS SDK CodeGen

The iOS CodeGen command line tool generates iOS client side LoopBack Model representations
in Swift by looking into the specified server application.

## How to Use

The following is an example usage applied to the test server provided under this directory:

 1. Run `npm install` in this directory to initialize the tool `bin/lb-ios` and the test server under `test-env/server`.
 *  Run `bin/lb-ios -p XX -s SS test-env/server/server test-env/client/ios/CodeGenTest/gen-src` 
    to generate the models in Objective-C representation, 
    where `XX` is the prefix and `SS` is the postfix attached to all the generated class names.

## How to Run the Unit Test

After performing the above steps, run the followings:

 1. `node test-env/server/server.js`
 *  `cd test-env/client/ios/CodeGenTest`
 *  `pod install`
 *  `open CodeGenTest.xcworkspace`
 *  Run the CodeGenTestTests unit tests.


## Limitations

 * Currently properties and simple method generation are supported.
    See the generated headers for details.

