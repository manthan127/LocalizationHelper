//
//  URL.swift
//  ReduceProjectSize
//
//  Created by Home on 29/01/25.
//

import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif
extension String {
    static let xcstrings = "xcstrings"
    static let pbxproj = "pbxproj"
    static let xcodeproj = "xcodeproj"
}

extension URL {
#if os(macOS)
    func showInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([self])
    }
#endif
    
    func fileExists()-> Bool {
        return FileManager.default.fileExists(atPath: self.path(percentEncoded: false))
    }
    
    // MARK: - Get Child of directory
    func subDirectories() throws -> [URL] {
        return try children(predicate: \.hasDirectoryPath)
    }
    
    func childFiles() throws -> [URL] {
        return try children(predicate: \.isFileURL)
    }
    
    func children(
        predicate: ((URL) -> Bool)? = nil,
        options: FileManager.DirectoryEnumerationOptions = []
    ) throws -> [URL] {
        let children = try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: options)
        
        if let predicate {
            return children.filter(predicate)
        } else {
            return children
        }
    }
    
    var memorySpace: Int64 {
        let attrs = try? FileManager.default.attributesOfItem(atPath: self.path(percentEncoded: false))
        return attrs?[.size] as? Int64 ?? 0
    }

    // MARK: - filetype checks
    var fileType: UTType? {
        try? self.resourceValues(forKeys: [.contentTypeKey]).contentType
    }
    
    func conformsTo(type: UTType)-> Bool {
         fileType?.conforms(to: type) ?? false
    }
    
    func conformsAny(_ types: [UTType])-> Bool {
        fileType.map { fileType in
            types.contains(where: { fileType.conforms(to: $0) })
        } ?? false
    }
}
