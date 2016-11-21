//
//  OLEHeader.swift
//  OLEBrowser
//
//  Created by Christoph Heinig on 31.05.16.
//  Copyright © 2016 chdev. All rights reserved.
//

import Foundation

class CFBHeader {

    // Variables
    var headerData:Data?;

    var signature:[UInt8]?;
    var clsid:[UInt8]?;

    var minorVersion:UInt16?;
    var majorVersion:UInt16?;

    var numberOfDIFATSectors:UInt32?;
    var numberOfDirectorySectors:UInt32?;
    var numberOfFATSectors:UInt32?;
    var numberOfMiniSectors:UInt32?;

    var startSectorDirectory:UInt32?;
    var startSectorMini:UInt32?;
    var startSectorDIFAT:UInt32?;

    var byteOrder:UInt16?;
    var sectorSize:UInt16?;
    var miniSectorSize:UInt16?;
    var miniCutoffSize:UInt32?;
    var transactionSignature:UInt32?;

    var difat = [UInt32]();

    let signatureRange = NSRange(location: 0, length: 8);
    let clsidRange = NSRange(location: 0x8, length: 0x18-0x8);

    let minorVersionRange = NSRange(location: 0x18, length: 0x1A-0x18);
    let majorVersionRange = NSRange(location: 0x1A, length: 0x1C-0x1A);

    let numberOfDIFATSectorsRange = NSRange(location: 0x48, length: 0x4C-0x48);
    let numberOfDirectorySectorsRange = NSRange(location: 0x28, length: 0x2C-0x28);
    let numberOfFATSectorsRange = NSRange(location: 0x2C, length: 0x30-0x2c);
    let numberOfMiniSectorsRange = NSRange(location: 0x40, length: 0x44-0x40);

    let startSectorDirectoryRange = NSRange(location: 0x30, length: 0x34-0x30);
    let startSectorMiniRange = NSRange(location: 0x3C, length: 0x40-0x3c);
    let startSectorDIFATRange = NSRange(location: 0x44, length: 0x48-0x44);

    let byteOrderRange = NSRange(location: 0x1C, length: 0x1E-0x1c);
    let sectorSizeRange = NSRange(location: 0x1E, length: 0x20-0x1e);
    let miniSectorSizeRange = NSRange(location: 0x20, length: 0x22-0x20);
    let miniCutoffSizeRange = NSRange(location: 0x38, length: 0x3C-0x38);
    let transactionSignatureRange = NSRange(location: 0x34, length: 0x38-0x34);

    let difatRange = NSRange(location: 0x4C, length: 0x200-0x4c);

    init(){
        // no init yet
    }

    // Init file header data
    func setHeaderData(_ headerData: Data) {
        self.headerData = headerData;
        // init data variables
        // getSignature();
        // getClsId();
        // getMinorVersion();
        // getMajorVersion();
        // getByteOrder();
        // getSectorSize();
        // getMiniSectorSize();
        // getNumberOfDirectorySectors();
        // getNumberOfFATSectors();
        // getNumberOfMiniSectors();
        // getNumberOfDIFATSectors();
        // getStartSectorDIFAT();
        // getStartSectorMiniFAT();
        // getStartSectorDirectory();
        // getTransactionSignature();
        // getMiniCutoffSize();
        // getDIFAT();
    }

    // Get Signature
    func getSignature() -> [UInt8] {
        if signature == nil {signature = getByteArray(signatureRange)};
        return signature!;
    }

    // Get CLSID
    func getClsId() -> [UInt8] {
        if clsid == nil {clsid = getByteArray(clsidRange)}
        return clsid!;
    }

    // Get Minor Version
    func getMinorVersion() -> UInt16 {
        if minorVersion == nil {
            minorVersion = UnsafePointer(getByteArray(minorVersionRange)).withMemoryRebound(to: UInt16.self, capacity: 1){$0.pointee;}
//            minorVersion = UnsafePointer<UInt16>(getByteArray(minorVersionRange)).pointee
        };
        return minorVersion!;
    }

    // Get Major Version
    func getMajorVersion() -> UInt16 {
        if majorVersion == nil {
            majorVersion = UnsafePointer(getByteArray(majorVersionRange)).withMemoryRebound(to: UInt16.self, capacity: 1){$0.pointee;}
//            majorVersion = UnsafePointer<UInt16>(getByteArray(majorVersionRange)).pointee
        };
        return majorVersion!;
    }

    // Get Byte Order
    func getByteOrder() -> UInt16 {
        if byteOrder == nil {
            byteOrder = UnsafePointer(getByteArray(byteOrderRange)).withMemoryRebound(to: UInt16.self, capacity: 1){$0.pointee;}
//            byteOrder = UnsafePointer<UInt16>(getByteArray(byteOrderRange)).pointee
        };
        return byteOrder!;
    }

    // Get Sector Size in byte
    func getSectorSize() -> UInt16 {
        if sectorSize == nil {
            sectorSize = UnsafePointer(getByteArray(sectorSizeRange)).withMemoryRebound(to: UInt16.self, capacity: 1){$0.pointee;}
//            sectorSize = UnsafePointer<UInt16>(getByteArray(sectorSizeRange)).pointee;
            sectorSize = 2 << (sectorSize!-1);
        }
        return sectorSize!;
    }

    // Get Mini Sector Size in byte
    func getMiniSectorSize() -> UInt16 {
        if miniSectorSize == nil {
            miniSectorSize = UnsafePointer(getByteArray(miniSectorSizeRange)).withMemoryRebound(to: UInt16.self, capacity: 1){$0.pointee;}
//            miniSectorSize = UnsafePointer<UInt16>(getByteArray(miniSectorSizeRange)).pointee;
            miniSectorSize = 2 << (miniSectorSize!-1);
        }
        return miniSectorSize!;
    }

    // Get Number of Directory Sectors
    func getNumberOfDirectorySectors() -> UInt32 {
        if numberOfDirectorySectors == nil {
            numberOfDirectorySectors = UnsafePointer(getByteArray(numberOfDirectorySectorsRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            numberOfDirectorySectors = UnsafePointer<UInt32>(getByteArray(numberOfDirectorySectorsRange)).pointee
        };
        return numberOfDirectorySectors!;
    }

    // Get Number of FAT Sectors
    func getNumberOfFATSectors() -> UInt32 {
        if numberOfFATSectors == nil {
            numberOfFATSectors = UnsafePointer(getByteArray(numberOfFATSectorsRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            numberOfFATSectors = UnsafePointer<UInt32>(getByteArray(numberOfFATSectorsRange)).pointee
        };
        return numberOfFATSectors!;
    }

    // Get Start Location of Directory Sectors
    func getStartSectorDirectory() -> UInt32 {
        if startSectorDirectory == nil {
            startSectorDirectory = UnsafePointer(getByteArray(startSectorDirectoryRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            startSectorDirectory = UnsafePointer<UInt32>(getByteArray(startSectorDirectoryRange)).pointee
        };
        return startSectorDirectory!;
    }

    // Get Transaction Signature
    func getTransactionSignature() -> UInt32 {
        if transactionSignature == nil {
            transactionSignature = UnsafePointer(getByteArray(transactionSignatureRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            transactionSignature = UnsafePointer<UInt32>(getByteArray(transactionSignatureRange)).pointee
        };
        return transactionSignature!;
    }

    // Get Mini Stream Cutoff Size
    func getMiniCutoffSize() -> UInt32 {
        if miniCutoffSize == nil {
            miniCutoffSize = UnsafePointer(getByteArray(miniCutoffSizeRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            miniCutoffSize = UnsafePointer<UInt32>(getByteArray(miniCutoffSizeRange)).pointee
        };
        return miniCutoffSize!;
    }

    // Get Start Location of Mini FAT Sectors
    func getStartSectorMiniFAT() -> UInt32 {
        if startSectorMini == nil {
            startSectorMini = UnsafePointer(getByteArray(startSectorMiniRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            startSectorMini = UnsafePointer<UInt32>(getByteArray(startSectorMiniRange)).pointee
        };
        return startSectorMini!;
    }

    // Get Number of Mini FAT Sectors
    func getNumberOfMiniSectors() -> UInt32 {
        if numberOfMiniSectors == nil {
            numberOfMiniSectors = UnsafePointer(getByteArray(numberOfMiniSectorsRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            numberOfMiniSectors = UnsafePointer<UInt32>(getByteArray(numberOfMiniSectorsRange)).pointee
        };
        return numberOfMiniSectors!;
    }

    // Get Start Location of DIFAT Sectors
    func getStartSectorDIFAT() -> UInt32 {
        if startSectorDIFAT == nil {
            startSectorDIFAT = UnsafePointer(getByteArray(startSectorDIFATRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            startSectorDIFAT = UnsafePointer<UInt32>(getByteArray(startSectorDIFATRange)).pointee
        };
        return startSectorDIFAT!;
    }

    // Get Number of DIFAT Sectors
    func getNumberOfDIFATSectors() -> UInt32 {
        if numberOfDIFATSectors == nil {
            numberOfDIFATSectors = UnsafePointer(getByteArray(numberOfDIFATSectorsRange)).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//            numberOfDIFATSectors = UnsafePointer<UInt32>(getByteArray(numberOfDIFATSectorsRange)).pointee
        };
        return numberOfDIFATSectors!;
    }

    // Get DIFAT
    func getDIFAT() -> [UInt32] {
        if difat.count <= 0 {
            for index in 0...108 {
                let array:[UInt8] = getByteArray(NSRange(location: 0x4C+index*4, length: 0x4C+(index+1)*4 - (0x4C+index*4)));
                let buffer = UnsafePointer(array).withMemoryRebound(to: UInt32.self, capacity: 1){$0.pointee;}
//                let buffer = UnsafePointer<UInt32>(array).pointee;
                //fatList.append(UInt32(fatData.bytes(NSRange(index*128...(index+1)*128-1)));
                difat.append(buffer);
            }
        }
        return difat;
    }

    // General byte reader
    func getByteArray(_ range: NSRange) -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: range.length);
        (headerData as NSData?)?.getBytes(&buffer, range: range)
        return buffer;
    }
}
