import AsyncHTTPClient
import Foundation
import Logging
import SotoElasticsearch
import SotoElasticsearchService
import Testing

@Suite(.serialized)
class SotoElasticSearchIntegrationTests {
    var client: SotoElasticsearchClient!
    var awsClient: AWSClient!
    let indexName = "some-index"
    let logger = Logger(label: "io.brokenhands.swift-soto-elasticsearch.test")

    init() async throws {
        var logger = Logger(label: "io.brokenhands.swift-soto-elasticsearch.test")
        logger.logLevel = .trace
        awsClient = AWSClient(
            credentialProvider: .static(accessKeyId: "SOMETHING", secretAccessKey: "SOMETHINGELSE"))
        client = try SotoElasticsearchClient(
            awsClient: awsClient, logger: logger, httpClient: .shared, host: "localhost")

        if try await client.checkIndexExists(indexName) {
            _ = try await client.deleteIndex(indexName)
        }
    }

    deinit {
        try! awsClient.syncShutdown()
    }

    @Test("Search Items")
    func testSearchingItems() async throws {
        try await setupItems()

        let results: ESGetMultipleDocumentsResponse<SomeItem> = try await client.searchDocuments(
            from: indexName, searchTerm: "Apples"
        )
        #expect(results.hits.hits.count == 5)
    }

    @Test("Search Items with Type Provided")
    func testSearchingItemsWithTypeProvided() async throws {
        try await setupItems()

        let results = try await client.searchDocuments(
            from: indexName, searchTerm: "Apples", type: SomeItem.self
        )
        #expect(results.hits.hits.count == 5)
    }

    @Test("Search Items Count")
    func testSearchItemsCount() async throws {
        try await setupItems()

        let results = try await client.searchDocumentsCount(from: indexName, searchTerm: "Apples")
        #expect(results.count == 5)
    }

    @Test("Create Document")
    func testCreateDocument() async throws {
        let item = SomeItem(id: UUID(), name: "Banana")
        let response = try await client.createDocument(item, in: self.indexName)
        #expect(item.id.uuidString != response.id)
        #expect(response.index == self.indexName)
        #expect(response.result == "created")
    }

    @Test("Create Document With ID")
    func testCreateDocumentWithID() async throws {
        let item = SomeItem(id: UUID(), name: "Banana")
        let response = try await client.createDocumentWithID(item, in: self.indexName)
        #expect(item.id == response.id)
        #expect(response.index == self.indexName)
        #expect(response.result == "created")
    }

    @Test("Update Document")
    func testUpdatingDocument() async throws {
        let item = SomeItem(id: UUID(), name: "Banana")
        _ = try await client.createDocumentWithID(item, in: self.indexName)
        try await Task.sleep(for: .seconds(0.5))
        let updatedItem = SomeItem(id: item.id, name: "Bananas")
        let response = try await client.updateDocument(
            updatedItem, id: item.id.uuidString, in: self.indexName
        )
        #expect(response.result == "updated")
    }

    @Test("Delete Document")
    func testDeletingDocument() async throws {
        try await setupItems()
        let item = SomeItem(id: UUID(), name: "Banana")
        _ = try await client.createDocumentWithID(item, in: self.indexName)
        try await Task.sleep(for: .seconds(1))

        let results = try await client.searchDocumentsCount(from: indexName, searchTerm: "Banana")
        #expect(results.count == 1)
        try await Task.sleep(for: .seconds(0.5))

        let response = try await client.deleteDocument(id: item.id.uuidString, from: self.indexName)

        #expect(response.result == "deleted")
        try await Task.sleep(for: .seconds(0.5))

        let updatedResults = try await client.searchDocumentsCount(
            from: indexName, searchTerm: "Banana")

        #expect(updatedResults.count == 0)
    }

    @Test("Index Exists")
    func testIndexExists() async throws {
        let item = SomeItem(id: UUID(), name: "Banana")
        let response = try await client.createDocument(item, in: self.indexName)
        #expect(response.index == self.indexName)
        #expect(response.result == "created")
        try await Task.sleep(for: .seconds(0.5))

        let exists = try await client.checkIndexExists(self.indexName)
        #expect(exists)

        let notExists = try await client.checkIndexExists("some-random-index")
        #expect(notExists == false)
    }

    @Test("Delete Index")
    func testDeleteIndex() async throws {
        let item = SomeItem(id: UUID(), name: "Banana")
        _ = try await client.createDocument(item, in: self.indexName)
        try await Task.sleep(for: .seconds(0.5))

        let exists = try await client.checkIndexExists(self.indexName)
        #expect(exists)

        let response = try await client.deleteIndex(self.indexName)
        #expect(response.acknowledged == true)

        let notExists = try await client.checkIndexExists(self.indexName)
        #expect(notExists == false)
    }

    @Test("Bulk Create")
    func testBulkCreate() async throws {
        var items = [SomeItem]()
        for index in 1...10 {
            let name: String
            if index % 2 == 0 {
                name = "Some \(index) Apples"
            } else {
                name = "Some \(index) Bananas"
            }
            let item = SomeItem(id: UUID(), name: name)
            items.append(item)
        }

        let itemsWithIndex = items.map {
            ESBulkOperation(
                operationType: .create, index: self.indexName, id: $0.id.uuidString, document: $0)
        }
        let response = try await client.bulk(itemsWithIndex)
        #expect(response.errors == false)
        #expect(response.items.count == 10)
        #expect(response.items.first?.create?.result == "created")
        try await Task.sleep(for: .seconds(1))

        let results = try await client.searchDocumentsCount(from: indexName, searchTerm: nil)
        #expect(results.count == 10)
    }

    @Test("Bulk Create/Update/Delete Index")
    func testBulkCreateUpdateDeleteIndex() async throws {
        let item1 = SomeItem(id: UUID(), name: "Item 1")
        let item2 = SomeItem(id: UUID(), name: "Item 2")
        let item3 = SomeItem(id: UUID(), name: "Item 3")
        let item4 = SomeItem(id: UUID(), name: "Item 4")
        let bulkOperation = [
            ESBulkOperation(
                operationType: .create, index: self.indexName, id: item1.id.uuidString,
                document: item1),
            ESBulkOperation(
                operationType: .index, index: self.indexName, id: item2.id.uuidString,
                document: item2),
            ESBulkOperation(
                operationType: .update, index: self.indexName, id: item3.id.uuidString,
                document: item3),
            ESBulkOperation(
                operationType: .delete, index: self.indexName, id: item4.id.uuidString,
                document: item4),
        ]

        let response = try await client.bulk(bulkOperation)
        #expect(response.items.count == 4)
        #expect(response.items[0].create != nil)
        #expect(response.items[1].index != nil)
        #expect(response.items[2].update != nil)
        #expect(response.items[3].delete != nil)
    }

    @Test("Search Items Paginated")
    func testSearchingItemsPaginated() async throws {
        for index in 1...100 {
            let name = "Some \(index) Apples"
            let item = SomeItem(id: UUID(), name: name)
            _ = try await client.createDocument(item, in: self.indexName)
        }

        // This is required for ES to settle and load the indexes to return the right results
        try await Task.sleep(for: .seconds(1))

        let results: ESGetMultipleDocumentsResponse<SomeItem> =
            try await client.searchDocumentsPaginated(
                from: indexName, searchTerm: "Apples", size: 20, offset: 10
            )
        #expect(results.hits.hits.count == 20)
        #expect(results.hits.hits.contains(where: { $0.source.name == "Some 11 Apples" }))
        #expect(results.hits.hits.contains(where: { $0.source.name == "Some 29 Apples" }))
    }

    @Test("Search Items With Type Provided Paginated")
    func testSearchingItemsWithTypeProvidedPaginated() async throws {
        for index in 1...100 {
            let name = "Some \(index) Apples"
            let item = SomeItem(id: UUID(), name: name)
            _ = try await client.createDocument(item, in: self.indexName)
        }

        // This is required for ES to settle and load the indexes to return the right results
        try await Task.sleep(for: .seconds(1))

        let results = try await client.searchDocumentsPaginated(
            from: indexName, searchTerm: "Apples", size: 20, offset: 10, type: SomeItem.self
        )
        #expect(results.hits.hits.count == 20)
        #expect(results.hits.hits.contains(where: { $0.source.name == "Some 11 Apples" }))
        #expect(results.hits.hits.contains(where: { $0.source.name == "Some 29 Apples" }))
    }

    private func setupItems() async throws {
        for index in 1...10 {
            let name: String
            if index % 2 == 0 {
                name = "Some \(index) Apples"
            } else {
                name = "Some \(index) Bananas"
            }
            let item = SomeItem(id: UUID(), name: name)
            _ = try await client.createDocument(item, in: self.indexName)
        }

        // This is required for ES to settle and load the indexes to return the right results
        try await Task.sleep(for: .seconds(1))
    }
}
