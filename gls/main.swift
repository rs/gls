//
//  main.swift
//  gls
//
//  Created by Olivier Poitrey on 9/6/15.
//  Copyright (c) 2015 Hackemist. All rights reserved.
//

import Foundation
import AppKit


var opt_showInvisibles = false
var opt_suffix = false

let options = "aF"
var buffer = Array(options.utf8).map { Int8($0) }

while  true {
    let option = Int(getopt(Process.argc, Process.unsafeArgv, buffer))
    if option == -1 {
        break
    }
    switch "\(UnicodeScalar(option))"
    {
    case "a":
        opt_showInvisibles = true
    case "F":
        opt_suffix = true
    case "?":
        let charOption = "\(UnicodeScalar(Int(optopt)))"
        print("usage: ls [-\(options)] [file ...]")
        exit(1)
    default:
        abort()
    }
}

var args : [String] = []
for index in optind..<Process.argc {
    args.append(String.fromCString(Process.unsafeArgv[Int(index)])!)
}

let graphicOutput = isatty(STDOUT_FILENO) != 0
let fileManager = NSFileManager.defaultManager()
let workspace = NSWorkspace.sharedWorkspace()

func listDirectory(path : NSURL) {
    // List directory content
    var items : [AnyObject]?

    let properties = [NSURLFileResourceTypeKey, NSURLIsExecutableKey]
    var options = NSDirectoryEnumerationOptions()
    if !opt_showInvisibles {
        options = .SkipsHiddenFiles
    }
    do {
        items = try fileManager.contentsOfDirectoryAtURL(path, includingPropertiesForKeys: properties, options: options)
    } catch let error as NSError {
        print(error.localizedDescription)
        exit(1)
    }
    showItems(items as! [NSURL])
}

func showItems(items : [NSURL]) {
    for url in items {
        let path = url.path!

        var type : String
        var exec : Bool
        do {
            // Fetch file info
            var rsrc: AnyObject?
            try url.getResourceValue(&rsrc, forKey: NSURLFileResourceTypeKey)
            type = (rsrc as? String)!
            try url.getResourceValue(&rsrc, forKey: NSURLIsExecutableKey)
            exec = (rsrc as? Bool)!
        } catch let error as NSError {
            print(error.localizedDescription)
            exit(1)
        }

        if graphicOutput {
            // Get file icon
            let icon = workspace.iconForFile(path)

            // Resize
            let scaledSize = NSSize(width: 16, height: 16)
            let scaledIcon = NSImage(size: scaledSize)
            scaledIcon.lockFocus()
            icon.drawInRect(NSRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height), fromRect: CGRect(origin: CGPointZero, size: icon.size), operation: NSCompositingOperation.CompositeSourceOver, fraction: CGFloat(1.0))
            scaledIcon.unlockFocus()

            // Convert to base64
            var data: NSData = scaledIcon.TIFFRepresentation!
            let bitmap: NSBitmapImageRep = NSBitmapImageRep(data: data)!
            data = bitmap.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])!
            let iconB64 = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())

            // Output line
            print("\u{001B}]1337;File=inline=1;height=1;width=2;preserveAspectRatio=true:", terminator: "")
            print(iconB64, terminator: "")
            print("\u{0007}", terminator: "")
        }
        print(url.lastPathComponent!, terminator: "")

        // Add file type specific info
        switch type {
        case NSURLFileResourceTypeDirectory:
            if opt_suffix {
                print("/", terminator: "")
            }
        case NSURLFileResourceTypeSymbolicLink:
            if opt_suffix {
                print("@", terminator: "")
            }
            do {
                let dest = try fileManager.destinationOfSymbolicLinkAtPath(path)
                print(" -> ", terminator: "")
                print(dest, terminator: "")
            } catch {
            }
        case NSURLFileResourceTypeSocket:
            if opt_suffix {
                print("=", terminator: "")
            }
        case NSURLFileResourceTypeSocket:
            if opt_suffix {
                print("|", terminator: "")
            }
        default:
            break
        }
        if exec && type != NSURLFileResourceTypeDirectory && opt_suffix {
            print("*", terminator: "")
        }
        print("") // Prints the CR
    }
}

// List given paths or current directory if no paths provided
if args.count >= 1 {
    var first = true
    var files : [NSURL] = []
    var dirs : [NSURL] = []
    for path in args {
        do {
            var url = NSURL(fileURLWithPath: path)
            var rsrc: AnyObject?
            try url.getResourceValue(&rsrc, forKey: NSURLFileResourceTypeKey)
            if rsrc as? String == NSURLFileResourceTypeDirectory {
                dirs.append(url)
            } else {
                files.append(url)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            exit(1)
        }
    }
    if files.count > 0 {
        first = false
        showItems(files)
    }
    for dir in dirs {
        if !first {
            print("")
        }
        first = false
        print(dir.relativePath!, ":", separator: "")
        listDirectory(dir)
    }
} else {
    listDirectory(NSURL(fileURLWithPath: "."))
}

