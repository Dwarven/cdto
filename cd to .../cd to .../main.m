//
//  main.m
//  cd to ...
//
//  Created by James Tuley on 10/9/19.
//  Copyright © 2019 Jay Tuley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ScriptingBridge/ScriptingBridge.h>

#import "Finder.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        FinderApplication* finder = [SBApplication applicationWithBundleIdentifier:@"com.apple.Finder"];
                
        FinderItem *target = [(NSArray*)[[finder selection] get] firstObject];
        FinderFinderWindow* findWin = [[finder FinderWindows] objectAtLocation:@1];
        findWin = [[finder FinderWindows] objectWithID:[NSNumber numberWithInteger: findWin.id]];
        bool selected = true;
        if (target == nil){
            target = [[findWin target] get];
            selected = false;
        }
        
        NSDictionary* itemProperties = [target properties];
        id originalItem = [itemProperties objectForKey:@"originalItem"];
        if (originalItem != nil && originalItem != [NSNull null]){
            target = originalItem;
        }
        
        NSString* fileUrl = [target URL];
        if(fileUrl != nil && ![fileUrl hasSuffix:@"/"] && selected){
            fileUrl = [fileUrl stringByDeletingLastPathComponent];
        }
        
        NSURL* url = [NSURL URLWithString:fileUrl];
        if (url) {
            NSURL *fileURL = [NSURL fileURLWithPath:[url.path stringByExpandingTildeInPath]];
            NSURL *appURL = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.googlecode.iterm2"];
            if (appURL) {
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                [[NSWorkspace sharedWorkspace] openURLs:@[fileURL]
                                   withApplicationAtURL:appURL
                                          configuration:[NSWorkspaceOpenConfiguration configuration]
                                      completionHandler:^(NSRunningApplication *app, NSError *error) {
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
        }
    }
}
