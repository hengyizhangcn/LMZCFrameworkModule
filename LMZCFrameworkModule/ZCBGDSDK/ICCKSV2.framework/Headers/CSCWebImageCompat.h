/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Jamie Pinkham
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <TargetConditionals.h>

#ifdef __OBJC_GC__
    #error CSCWebImage does not support Objective-C Garbage Collection
#endif

// Seems like TARGET_OS_MAC is always defined (on all platforms).
// To determine if we are running on macOS, use TARGET_OS_OSX in Xcode 8
#if TARGET_OS_OSX
    #define CSC_MAC 1
#else
    #define CSC_MAC 0
#endif

// iOS and tvOS are very similar, UIKit exists on both platforms
// Note: watchOS also has UIKit, but it's very limited
#if TARGET_OS_IOS || TARGET_OS_TV
    #define CSC_UIKIT 1
#else
    #define CSC_UIKIT 0
#endif

#if TARGET_OS_IOS
    #define CSC_IOS 1
#else
    #define CSC_IOS 0
#endif

#if TARGET_OS_TV
    #define CSC_TV 1
#else
    #define CSC_TV 0
#endif

#if TARGET_OS_WATCH
    #define CSC_WATCH 1
#else
    #define CSC_WATCH 0
#endif


#if CSC_MAC
    #import <AppKit/AppKit.h>
    #ifndef UIImage
        #define UIImage NSImage
    #endif
    #ifndef UIImageView
        #define UIImageView NSImageView
    #endif
    #ifndef UIView
        #define UIView NSView
    #endif
    #ifndef UIColor
        #define UIColor NSColor
    #endif
#else
    #if CSC_UIKIT
        #import <UIKit/UIKit.h>
    #endif
    #if CSC_WATCH
        #import <WatchKit/WatchKit.h>
        #ifndef UIView
            #define UIView WKInterfaceObject
        #endif
        #ifndef UIImageView
            #define UIImageView WKInterfaceImage
        #endif
    #endif
#endif

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

#ifndef NS_OPTIONS
#define NS_OPTIONS(_type, _name) enum _name : _type _name; enum _name : _type
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif
