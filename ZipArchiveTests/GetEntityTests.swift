//
//  GetEntityTest.swift
//  ZipArchive
//
//  Created by Bradly Andalman on 1/14/26.
//

import Testing
import Foundation
import ZipArchive

struct GetEntityTests {
    enum TestError: Error {
        case couldNotFindTestBundle
        case couldNotFindArchive
    }
    
    /// Returns the zip file named `basename` in the test bundle
    private func zipFileURL(basename: String) throws -> URL {
        guard let bundle = Bundle(identifier: "co.180g.ZipArchiveTests") else {
            throw TestError.couldNotFindTestBundle
        }
        
        guard let zipURL = bundle.url(forResource: basename, withExtension: "zip") else {
            throw TestError.couldNotFindArchive
        }

        return zipURL
    }
    
    // MARK: Get Entity Names
    
    /// Function that lists all of the entities in a zip file named `archiveBasename`,
    /// and ensures they exactly match `expectedEntities`
    private func ensure(archiveBasename: String, hasEntities expectedEntities: [String]) throws {
        let zipURL = try zipFileURL(basename: archiveBasename)
        let entities = try SSZipArchive.getEntityNamesFromFile(atPath: zipURL.path)
        #expect(entities == expectedEntities)
    }

    @Test func testGetEntityNamesForTestArchive() async throws {
        try ensure(archiveBasename: "TestArchive", hasEntities: ["LICENSE", "Readme.markdown"])
    }
    
    @Test func testGetEntityNamesForHelloArchive() async throws {
        try ensure(archiveBasename: "hello", hasEntities: ["hello"])
    }

    @Test func testGetEntityNamesForUnicodeArchive() async throws {
        try ensure(archiveBasename: "Unicode", hasEntities: ["Accént.txt", "Fólder/Nothing.txt"])
    }

    @Test func testGetEntityNamesForEmptyArchive() async throws {
        try ensure(archiveBasename: "Empty", hasEntities: [])
    }
    
    // MARK: Get Entity (data)
    
    /// Function that extracts the `entityName` from the zip file named `archiveBasename`
    /// and ensures that its contents match `expectedContents`
    private func entityContents(archiveBasename: String, entityName: String) throws -> String? {
        let zipURL = try zipFileURL(basename: archiveBasename)
        let entityData = try SSZipArchive.unzipEntityName(entityName, fromFilePath: zipURL.path)
        let entityString = String(data: entityData, encoding: .utf8)
        return entityString?.trimmingCharacters(in: .newlines)
    }
    
    @Test func testGetEntityDataForUnicodeArchive() async throws {
        let helloEntityContents = try entityContents(archiveBasename: "Unicode", entityName: "Accént.txt")
        let helloExpectedContents = "Hello."
        #expect(helloEntityContents == helloExpectedContents)
    
        let nothingEntityContents = try entityContents(archiveBasename: "Unicode", entityName: "Fólder/Nothing.txt")
        let nothingExpectedContents = "Nothing to see here. Move along."
        #expect(nothingEntityContents == nothingExpectedContents)
    }
    
    @Test func testGetEntityDataFailure() async throws {
        // It's an error to ask for an entity that doesn't exist in the archive
        await #expect(throws: NSError.self) {
            try await entityContents(archiveBasename: "TestArchive", entityName: "BadEntityName.txt")
        }
    }
}
