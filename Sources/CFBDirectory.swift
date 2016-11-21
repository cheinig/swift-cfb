//
//  OLEDirectoryEntry.swift
//  OLEBrowser
//
//  Created by Christoph Heinig on 31.05.16.
//  Copyright © 2016 chdev. All rights reserved.
//

import Foundation

class CFBDirectory {
    
    
    unowned let cfbFile:CFBFile;
    var entryList = [CFBDirectoryEntry]();
    
    init(cfbFile: CFBFile){
        self.cfbFile = cfbFile;
    }
    
    func addSectorToDirectory(_ directoryData: Data, directorySector: UInt32){
        for index in 0...directoryData.count/128-1 {
            entryList.append(CFBDirectoryEntry(entryData: directoryData.subdata(in: Range(index*128...(index+1)*128-1)), directorySector: directorySector, streamID: entryList.count, cfbFile: cfbFile));
        }
    }
    
    func getRootEntry() -> CFBDirectoryEntry {
            return entryList[0];
    }
    
    func getEntryById(_ id: Int) -> CFBDirectoryEntry {
        return entryList[id];
    }
    
    
    


}
