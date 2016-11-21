//
//  OLEFile.swift
//  OLEBrowser
//
//  Created by Christoph Heinig on 31.05.16.
//  Copyright © 2016 chdev. All rights reserved.
//

import Foundation


class CFBFile {

    // Constants
    static let BYTE_ORDER_LE:UInt16 = 0xFFFE;
    static let SECTOR_MAXREGSECT:UInt32 = 0xFFFFFFFA;
    static let SECTOR_RESERVED:UInt32 = 0xFFFFFFFB;
    static let SECTOR_DIFAT:UInt32 = 0xFFFFFFFC;
    static let SECTOR_FAT:UInt32 = 0xFFFFFFFD;
    static let SECTOR_ENDOFCHAIN:UInt32 = 0xFFFFFFFE;
    static let SECTOR_FREE:UInt32 = 0xFFFFFFFF;
    static let SECTOR_RANGELOCK:UInt32 = 0x7FFFFFFF;
    static let HEADER_SIGNATURE:UInt64=0xE11AB1A1E011CFD0;
    static let DIRECTORY_TYPE_ROOT:UInt8 = 0x05;
    static let DIRECTORY_TYPE_STORAGE:UInt8 = 0x01;
    static let DIRECTORY_TYPE_STREAM:UInt8 = 0x02;
    static let DIRECTORY_TYPE_UNUSED:UInt8 = 0x00;
    
    let fileURL:URL;
    let fileHandle:FileHandle;
    var fatList=[UInt32]();
    var minifatList=[UInt32]();
    var miniStreamChain=[UInt32]();
    var difatList=[UInt32]();
    
    var directory: CFBDirectory!;
    let header = CFBHeader();
    
    init(fileURL: URL) throws {
        
        self.fileURL = fileURL;

        fileHandle = try FileHandle(forReadingFrom: fileURL);
        
        print("Reading file header...");
        header.setHeaderData(fileHandle.readData(ofLength: 512));
       
        // Skip next bytes until 4096 in case of version 4 file
        fileHandle.seek(toFileOffset: UInt64(header.getSectorSize()));
        
        // Fill DIFAT
        //header.getDIFAT();
        difatList.append(contentsOf: header.getDIFAT());
        if header.getNumberOfDIFATSectors()>0 {
            var currentDifatSector = header.getStartSectorDIFAT();
            while currentDifatSector != CFBFile.SECTOR_ENDOFCHAIN {
                fileHandle.seek(toFileOffset: UInt64(header.getSectorSize())*UInt64(currentDifatSector+1));
                currentDifatSector = addSectorToDIFAT(fileHandle.readData(ofLength: Int(header.getSectorSize())), difatSector: currentDifatSector);
            }
        }
        print("DIFAT: \(difatList)");
        
        // Fill FAT
        for fatSectorNumber in  difatList {
            if fatSectorNumber != CFBFile.SECTOR_FREE {
                fileHandle.seek(toFileOffset: UInt64(header.getSectorSize())*UInt64(fatSectorNumber+1));
                addSectorToFAT(fileHandle.readData(ofLength: Int(header.getSectorSize())), fatSector: fatSectorNumber);
            }
        }
        print("FAT: \(fatList)");
        
        // Fill MiniFAT
        var currentMiniFATSector = header.getStartSectorMiniFAT();
        print("Mini FAT Start Sector: \(currentMiniFATSector)");
        while currentMiniFATSector != CFBFile.SECTOR_ENDOFCHAIN {
            fileHandle.seek(toFileOffset: UInt64(header.getSectorSize())*UInt64(currentMiniFATSector+1));
            addSectorToMiniFAT(fileHandle.readData(ofLength: Int(header.getSectorSize())), minifatSector: currentMiniFATSector);
            currentMiniFATSector = fatList[Int(currentMiniFATSector)];
        }
        print("miniFAT: \(minifatList)");
        
        // Create DirectoryEntries
        directory = CFBDirectory(cfbFile: self);
        var currentDirectorySector = header.getStartSectorDirectory()
        print("Directory Start Sector: \(currentDirectorySector)");
        while currentDirectorySector != CFBFile.SECTOR_ENDOFCHAIN {
            fileHandle.seek(toFileOffset: UInt64(header.getSectorSize())*UInt64(currentDirectorySector+1));
            directory.addSectorToDirectory(fileHandle.readData(ofLength: Int(header.getSectorSize())), directorySector: currentDirectorySector);
            currentDirectorySector = fatList[Int(currentDirectorySector)];
        }
        
        // Fill MiniStreamChain
        var currentMiniStreamSector = directory.getRootEntry().getStartingSectorLocation();
        print("Mini Stream Start Sector: \(currentMiniStreamSector)");
        while currentMiniStreamSector != CFBFile.SECTOR_ENDOFCHAIN {
            fileHandle.seek(toFileOffset: UInt64(header.getSectorSize())*UInt64(currentMiniStreamSector+1));
            addSectorToMiniStreamChain(fileHandle.readData(ofLength: Int(header.getSectorSize())), miniStreamSector: currentMiniStreamSector);
            currentMiniStreamSector = fatList[Int(currentMiniStreamSector)];
        }
        
        
        // Debug print
        for directoryEntry in directory.entryList {
            if directoryEntry.getType() != CFBFile.DIRECTORY_TYPE_UNUSED {
                print("Directory name: \(directoryEntry.getName()) SI: \(directoryEntry.streamID) LS: \(directoryEntry.getLeftSibling()) RS: \(directoryEntry.getRightSibling()) CID: \(directoryEntry.getChildID()) SS: \(directoryEntry.getStartingSectorLocation())");
            }
        }
    }
    
    func addSectorToDIFAT(_ difatData: Data, difatSector: UInt32) -> UInt32 {
        for index in 0...difatData.count/4-5 {
            let array:[UInt8] = getByteArray(difatData, range: NSRange(location: index*4, length: (index+1)*4 - index*4));
            let buffer = UnsafePointer(array).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            let buffer = UnsafePointer<UInt32>(array).pointee;
            //fatList.append(UInt32(fatData.bytes(NSRange(index*128...(index+1)*128-1)));
            fatList.append(buffer);
        }
        // Get last difat chaining address
        return UnsafePointer(getByteArray(difatData, range: NSRange(location: difatData.count-5, length: difatData.count - (difatData.count-5)))).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//        return UnsafePointer<UInt32>(getByteArray(difatData, range: NSRange(location: difatData.count-5, length: difatData.count-1 - (difatData.count-5)))).pointee;
    }
    
    func addSectorToFAT(_ fatData: Data, fatSector: UInt32){
        for index in 0...fatData.count/4-1 {
            let array:[UInt8] = getByteArray(fatData, range: NSRange(location: index*4, length: (index+1)*4 - index*4));
            let buffer = UnsafePointer(array).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            let buffer = UnsafePointer<UInt32>(array).pointee;
            //fatList.append(UInt32(fatData.bytes(NSRange(index*128...(index+1)*128-1)));
            fatList.append(buffer);
        }
    }
    
    func addSectorToMiniFAT(_ minifatData: Data, minifatSector: UInt32){
        for index in 0...minifatData.count/4-1 {
            let array:[UInt8] = getByteArray(minifatData, range: NSRange(location: index*4, length: (index+1)*4 - index*4));
            let buffer = UnsafePointer(array).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            let buffer = UnsafePointer<UInt32>(array).pointee;
            //fatList.append(UInt32(fatData.bytes(NSRange(index*128...(index+1)*128-1)));
            minifatList.append(buffer);
        }
    }
    
    func addSectorToMiniStreamChain(_ miniStreamData: Data, miniStreamSector: UInt32){
        for index in 0...miniStreamData.count/4-1 {
            let array:[UInt8] = getByteArray(miniStreamData, range: NSRange(location: index*4, length: (index+1)*4 - index*4));
            let buffer = UnsafePointer(array).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            let buffer = UnsafePointer<UInt32>(array).pointee;
            //fatList.append(UInt32(fatData.bytes(NSRange(index*128...(index+1)*128-1)));
            miniStreamChain.append(buffer);
        }
    }
    
    // General byte reader
    func getByteArray(_ data: Data, range: NSRange) -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: range.length);
        (data as NSData).getBytes(&buffer, range: range)
        return buffer;
    }
    
    // Get Sector Data
    func getSectorData(_ sectorNumber:UInt32) -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: Int(header.getSectorSize()));
        fileHandle.seek(toFileOffset: UInt64(header.getSectorSize())*UInt64(sectorNumber+1));
        (fileHandle.readData(ofLength: Int(header.getSectorSize())) as NSData).getBytes(&buffer, length: Int(header.getSectorSize()));
        return buffer;
    }
    
    // Get Mini Sector Data
    func getMiniSectorData(_ miniSectorNumber:UInt32) -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: Int(header.getMiniSectorSize()));
        // Calculate miniStream offset
        let miniSectorNumber:Int = Int(miniSectorNumber/UInt32(header.getSectorSize()/header.getMiniSectorSize()));
        let sectorNumber:UInt32 = miniStreamChain[miniSectorNumber];
        let miniStreamNumber:Int = Int(miniSectorNumber) % Int(header.getSectorSize()/header.getMiniSectorSize());
        let offset:UInt64 = (UInt64(header.getMiniSectorSize())*UInt64(sectorNumber+1))+UInt64(miniStreamNumber);
        
        fileHandle.seek(toFileOffset: offset);
        (fileHandle.readData(ofLength: Int(header.getMiniSectorSize())) as NSData).getBytes(&buffer, length: Int(header.getMiniSectorSize()));
        return buffer;
    }
}
