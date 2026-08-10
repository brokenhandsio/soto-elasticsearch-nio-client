import AsyncHTTPClient
@_exported import Elasticsearch
import Foundation
import SotoElasticsearchService

public struct SotoElasticsearchClient {
    public let elasticSearchClient: ElasticsearchClient

    public init(
        awsClient: AWSClient,
        region: Region? = nil,
        logger: Logger,
        httpClient: HTTPClient,
        scheme: String = "http",
        host: String,
        port: Int? = 9200,
        username: String? = nil,
        password: String? = nil,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) throws {
        let requester = SotoElasticsearchRequester(
            awsClient: awsClient,
            region: region,
            logger: logger,
            client: httpClient
        )
        self.elasticSearchClient = try ElasticsearchClient(
            requester: requester,
            logger: logger,
            scheme: scheme,
            host: host,
            port: port,
            username: username,
            password: password,
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder
        )
    }

    public func get<Document: Decodable>(id: String, from indexName: String) async throws -> ESGetSingleDocumentResponse<Document> {
        try await self.elasticSearchClient.get(id: id, from: indexName)
    }

    public func bulk<Document: Encodable>(_ operations: [ESBulkOperation<Document, String>]) async throws -> ESBulkResponse {
        try await self.elasticSearchClient.bulk(operations)
    }

    public func createDocument<Document: Encodable>(
        _ document: Document, in indexName: String
    ) async throws -> ESCreateDocumentResponse<String> {
        try await self.elasticSearchClient.createDocument(document, in: indexName)
    }

    public func createDocumentWithID<Document: Encodable & Identifiable>(
        _ document: Document, in indexName: String
    ) async throws -> ESCreateDocumentResponse<Document.ID> {
        try await self.elasticSearchClient.createDocumentWithID(document, in: indexName)
    }

    public func updateDocument<Document: Encodable, ID: Hashable>(
        _ document: Document, id: ID, in indexName: String
    ) async throws -> ESUpdateDocumentResponse<ID> {
        try await self.elasticSearchClient.updateDocument(document, id: id, in: indexName)
    }

    public func updateDocument<Document: Encodable & Identifiable>(
        _ document: Document, in indexName: String
    ) async throws -> ESUpdateDocumentResponse<Document.ID> {
        try await self.elasticSearchClient.updateDocument(document, in: indexName)
    }

    public func updateDocumentWithScript<Script: Encodable, ID: Hashable>(
        _ script: Script, id: ID, in indexName: String
    ) async throws -> ESUpdateDocumentResponse<ID> {
        try await self.elasticSearchClient.updateDocumentWithScript(script, id: id, in: indexName)
    }

    public func deleteDocument<ID: Hashable>(id: ID, from indexName: String) async throws -> ESDeleteDocumentResponse {
        try await self.elasticSearchClient.deleteDocument(id: id, from: indexName)
    }

    public func searchDocuments<Document: Decodable>(
        from indexName: String, searchTerm: String, type: Document.Type = Document.self
    ) async throws -> ESGetMultipleDocumentsResponse<Document> {
        try await self.elasticSearchClient.searchDocuments(from: indexName, searchTerm: searchTerm, type: type)
    }

    public func searchDocumentsCount(from indexName: String, searchTerm: String?) async throws -> ESCountResponse {
        try await self.elasticSearchClient.searchDocumentsCount(from: indexName, searchTerm: searchTerm)
    }

    public func searchDocumentsPaginated<Document: Decodable>(
        from indexName: String, searchTerm: String, size: Int = 10, offset: Int = 0,
        type: Document.Type = Document.self
    ) async throws -> ESGetMultipleDocumentsResponse<Document> {
        try await self.elasticSearchClient.searchDocumentsPaginated(
            from: indexName, searchTerm: searchTerm, size: size, offset: offset, type: type)
    }

    public func searchDocumentsCount<Query: Encodable>(from indexName: String, query: Query) async throws -> ESCountResponse {
        try await self.elasticSearchClient.searchDocumentsCount(from: indexName, query: query)
    }

    public func searchDocumentsPaginated<Document: Decodable, QueryBody: Encodable>(
        from indexName: String, queryBody: QueryBody, size: Int = 10, offset: Int = 0,
        type: Document.Type = Document.self
    ) async throws -> ESGetMultipleDocumentsResponse<Document> {
        try await self.elasticSearchClient.searchDocumentsPaginated(
            from: indexName, queryBody: queryBody, size: size, offset: offset, type: type)
    }

    public func customSearch<Document: Decodable, Query: Encodable>(
        from indexName: String, query: Query, type: Document.Type = Document.self
    ) async throws -> ESGetMultipleDocumentsResponse<Document> {
        try await self.elasticSearchClient.customSearch(from: indexName, query: query, type: type)
    }

    public func deleteIndex(_ name: String) async throws -> ESAcknowledgedResponse {
        try await self.elasticSearchClient.deleteIndex(name)
    }

    public func checkIndexExists(_ name: String) async throws -> Bool {
        try await self.elasticSearchClient.checkIndexExists(name)
    }
}
