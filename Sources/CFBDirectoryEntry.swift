//
//  CFBDirectoryEntry.swift
//  OLEBrowser
//
//  Created by Christoph Heinig on 10.06.16.
//  Copyright © 2016 chdev. All rights reserved.
//

import Foundation

class CFBDirectoryEntry {
    let entryData:Data?;
    unowned let cfbFile:CFBFile;
    var directorySector:UInt32;
    var streamID = 0;

    let nameRange = NSRange(location: 0, length: 0x40);
    let lengthRange = NSRange(location: 0x40, length: 0x42-0x40);
    let typeRange = NSRange(location: 0x42, length: 0x43-0x42);
    let colorFlagRange = NSRange(location: 0x43, length: 0x44-0x43);
    let leftSiblingRange = NSRange(location: 0x44, length: 0x48-0x44);
    let rightSiblingRange = NSRange(location: 0x48, length: 0x4C-0x48);
    let childIDRange = NSRange(location: 0x4C, length: 0x50-0x4c);
    let clsIDRange = NSRange(location: 0x50, length: 0x60-0x50);
    let stateFlagsRange = NSRange(location: 0x60, length: 0x64-0x60);
    let creationTimeRange = NSRange(location: 0x64, length: 0x6C-0x64);
    let modificationTimeRange = NSRange(location: 0x6C, length: 0x74-0x6c);
    let startingSectorLocationRange = NSRange(location: 0x74, length: 0x78-0x74);
    let streamSizeRange = NSRange(location: 0x78, length: 0x7F-0x78);

    var name:String?;
    var length:UInt16?;
    var type:UInt8?;
    var colorFlag:UInt8?;
    var leftSibling:UInt32?;
    var rightSibling:UInt32?;
    var childID:UInt32?;
    var clsID:[UInt8]?;
    var stateFlags:UInt32?;
    var creationTime:UInt64?;
    var modificationTime:UInt64?;
    var startingSectorLocation:UInt32?;
    var streamSize:UInt64?;

    init(entryData: Data, directorySector: UInt32, streamID: Int, cfbFile: CFBFile){
        self.entryData=entryData;
        self.directorySector = directorySector;
        self.streamID = streamID;
        self.cfbFile = cfbFile;

        // init all values for better debugging
        // getName();
        // getLength();
        // getType();
        // getColorFlag();
        // getLeftSibling();
        // getRightSibling();
        // getChildID();
        // getClsID();
        // getStateFlags();
        // getCreationTime();
        // getModificationTime();
        // getStartingSectorLocation();
        // getStreamSize();
    }

    // Get Name
    func getName() -> String {
        if name == nil {name = String(bytes: getByteArray(nameRange), encoding: String.Encoding.utf16LittleEndian)!.trimmingCharacters(in: CharacterSet.controlCharacters)};
        return name!;
    }

    // Get length
    func getLength() -> UInt16 {
        if length == nil {
            length = UnsafePointer(getByteArray(lengthRange)).withMemoryRebound(to: UInt16.self, capacity: 1){$0.pointee;}
//            length = UnsafePointer<UInt16>(getByteArray(lengthRange)).pointee
        };
        return length!;
    }

    // Get type
    func getType() -> UInt8 {
        if type == nil {
            type = UnsafePointer(getByteArray(typeRange)).withMemoryRebound(to: UInt8.self, capacity: 1){$0.pointee;}
//            type = UnsafePointer<UInt8>(getByteArray(typeRange)).pointee
        };
        return type!;
    }

    // Get colorFlag
    func getColorFlag() -> UInt8 {
        if colorFlag == nil {
            colorFlag = UnsafePointer(getByteArray(colorFlagRange)).withMemoryRebound(to: UInt8.self, capacity: 1){$0.pointee;}
//            colorFlag = UnsafePointer<UInt8>(getByteArray(colorFlagRange)).pointee
        };
        return colorFlag!;
    }

    // Get leftSibling
    func getLeftSibling() -> UInt32 {
        if leftSibling == nil {
            leftSibling = UnsafePointer(getByteArray(leftSiblingRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            leftSibling = UnsafePointer<UInt32>(getByteArray(leftSiblingRange)).pointee
        };
        return leftSibling!;
    }

    // Get rightSibling
    func getRightSibling() -> UInt32 {
        if rightSibling == nil {
            rightSibling = UnsafePointer(getByteArray(rightSiblingRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            rightSibling = UnsafePointer<UInt32>(getByteArray(rightSiblingRange)).pointee
        };
        return rightSibling!;
    }

    // Get childID
    func getChildID() -> UInt32 {
        if childID == nil {
            childID = UnsafePointer(getByteArray(childIDRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            childID = UnsafePointer<UInt32>(getByteArray(childIDRange)).pointee
        };
        return childID!;
    }

    // Get clsID
    func getClsID() -> [UInt8] {
        if clsID == nil {clsID = getByteArray(clsIDRange)};
        return clsID!;
    }

    // Get stateFlags
    func getStateFlags() -> UInt32 {
        if stateFlags == nil {
            stateFlags = UnsafePointer(getByteArray(stateFlagsRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            stateFlags = UnsafePointer<UInt32>(getByteArray(stateFlagsRange)).pointee
        };
        return stateFlags!;
    }

    // Get creationTime
    func getCreationTime() -> UInt64 {
        if creationTime == nil {
            creationTime = UnsafePointer(getByteArray(creationTimeRange)).withMemoryRebound(to: UInt64.self, capacity: 1){$0.pointee;}
//            creationTime = UnsafePointer<UInt64>(getByteArray(creationTimeRange)).pointee
        };
        return creationTime!;
    }

    // Get modificationTime
    func getModificationTime() -> UInt64 {
        if modificationTime == nil {
            modificationTime = UnsafePointer(getByteArray(modificationTimeRange)).withMemoryRebound(to: UInt64.self, capacity: 1){$0.pointee;}
//            modificationTime = UnsafePointer<UInt64>(getByteArray(modificationTimeRange)).pointee
        };
        return modificationTime!;
    }

    // Get startingSectorLocation
    func getStartingSectorLocation() -> UInt32 {
        if startingSectorLocation == nil {
            startingSectorLocation = UnsafePointer(getByteArray(startingSectorLocationRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            startingSectorLocation = UnsafePointer<UInt32>(getByteArray(startingSectorLocationRange)).pointee
        };
        return startingSectorLocation!;
    }

    // Get streamSize
    func getStreamSize() -> UInt64 {
        if streamSize == nil {
            streamSize = UnsafePointer(getByteArray(streamSizeRange)).withMemoryRebound(to: UInt64.self, capacity: 1){$0.pointee;}
//            streamSize = UnsafePointer<UInt64>(getByteArray(streamSizeRange)).pointee
        };
        return streamSize!;
    }

    // General byte reader
    func getByteArray(_ range: NSRange) -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: range.length);
        (entryData as NSData?)?.getBytes(&buffer, range: range)
        return buffer;
    }
}
