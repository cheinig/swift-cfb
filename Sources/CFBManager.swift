//
//  CFBManager.swift
//  CFBBrowser
//
//  Created by Christoph Heinig on 31.05.16.
//  Copyright © 2016 chdev. All rights reserved.
//

import Foundation

class CFBManager {
    
    // Singleton
    static let instance = CFBManager()
    fileprivate init(){};
    
    var cfbFile:CFBFile?;
    
    func createCFBFileObjectFromFile(_ url: URL) -> CFBFile {
        
        do {
            cfbFile = try CFBFile(fileURL: url);
        } catch _ {
            print("Cannot create CFBFile object with the URL: \(url)");
        }
            
        return cfbFile!;
    }

    func getDataFromDirectoryEntry(_ directoryEntry: CFBDirectoryEntry) -> [UInt8] {
        var data = [UInt8]();
        
        // Check if directory entry is a stream object
        if directoryEntry.getType() == CFBFile.DIRECTORY_TYPE_STREAM {
            // Check if stream item is stored in mini stream
            if directoryEntry.getStreamSize() >= UInt64((cfbFile?.header.getMiniCutoffSize())!) {
                // Normal sectors are used
                var sectorChain = [UInt32]();
                sectorChain.append(directoryEntry.getStartingSectorLocation());
                while sectorChain.last! != CFBFile.SECTOR_ENDOFCHAIN {
                    sectorChain.append((cfbFile!.fatList[Int(sectorChain.last!)]));
                }
                for currentSector in sectorChain {
                    data.append(contentsOf: cfbFile!.getSectorData(currentSector));
                }
            } else {
                // Mini sectors are used
                var sectorChain = [UInt32]();
                sectorChain.append(directoryEntry.getStartingSectorLocation());
                while sectorChain.last! != CFBFile.SECTOR_ENDOFCHAIN {
                    sectorChain.append((cfbFile?.minifatList[Int(sectorChain.last!)])!);
                }
                for currentSector in sectorChain {
                    data.append(contentsOf: cfbFile!.getMiniSectorData(currentSector));
                }
            }
        }
        
        return data;
    }
    
    func getDirectoryChildEntries(_ parentEntry: CFBDirectoryEntry) -> [CFBDirectoryEntry] {
        let childId = parentEntry.childID;
        var childEntries = [CFBDirectoryEntry]();
        
        if childId != nil && childId != CFBFile.SECTOR_FREE {
            let childEntry = parentEntry.cfbFile.directory.getEntryById(Int(parentEntry.childID!));
            childEntries.append(contentsOf: getDirectoryNeighbors(childEntry));
        }
        
        return childEntries;
    }
    
    
    // Recursion inside
    fileprivate func getDirectoryNeighbors(_ entry: CFBDirectoryEntry) -> [CFBDirectoryEntry] {
        var neighbors = [CFBDirectoryEntry]();
        let leftNeighborId = entry.leftSibling;
        let rightNeighborId = entry.rightSibling;
        
        if leftNeighborId != nil && leftNeighborId != CFBFile.SECTOR_FREE {
            // Recursion
            neighbors.append(contentsOf: getDirectoryNeighbors(entry.cfbFile.directory.getEntryById(Int(leftNeighborId!))));
        }
        
        if rightNeighborId != nil && rightNeighborId != CFBFile.SECTOR_FREE {
            // Recursion
            neighbors.append(contentsOf: getDirectoryNeighbors(entry.cfbFile.directory.getEntryById(Int(rightNeighborId!))));
        }
        
        neighbors.append(entry);
        
        return neighbors;
    }
}
