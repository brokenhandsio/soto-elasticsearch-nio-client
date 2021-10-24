@_exported import ElasticsearchNIOClient
import SotoElasticsearchService
import AsyncHTTPClient
import Foundation

public struct SotoElasticsearchClient {
    public let elasticSearchClient: ElasticsearchClient

    public init(awsClient: AWSClient, region: Region? = nil, eventLoop: EventLoop, context: LoggingContext, httpClient: HTTPClient, scheme: String = "http", host: String, port: Int? = 9200, username: String? = nil, password: String? = nil, jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        let requester = SotoElasticsearchRequester(awsClient: awsClient, region: region, eventLoop: eventLoop, context: context, client: httpClient)
        self.elasticSearchClient = ElasticsearchClient(requester: requester, eventLoop: eventLoop, context: context, scheme: scheme, host: host, port: port, username: username, password: password, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
    }

    public func get<Document: Decodable>(id: String, from indexName: String) -> EventLoopFuture<ESGetSingleDocumentResponse<Document>> {
        self.elasticSearchClient.get(id: id, from: indexName)
    }

    public func bulk<Document: Encodable>(_ operations: [ESBulkOperation<Document>]) -> EventLoopFuture<ESBulkResponse> {
        self.elasticSearchClient.bulk(operations)
    }

    public func createDocument<Document: Encodable>(_ document: Document, in indexName: String) -> EventLoopFuture<ESCreateDocumentResponse> {
        self.elasticSearchClient.createDocument(document, in: indexName)
    }

    public func createDocumentWithID<Document: Encodable & Identifiable>(_ document: Document, in indexName: String) -> EventLoopFuture<ESCreateDocumentResponse> {
        self.elasticSearchClient.createDocumentWithID(document, in: indexName)
    }

    public func updateDocument<Document: Encodable>(_ document: Document, id: String, in indexName: String) -> EventLoopFuture<ESUpdateDocumentResponse> {
        self.elasticSearchClient.updateDocument(document, id: id, in: indexName)
    }

    public func updateDocumentWithScript<Script: Encodable>(_ script: Script, id: String, in indexName: String) -> EventLoopFuture<ESUpdateDocumentResponse> {
        self.elasticSearchClient.updateDocumentWithScript(script, id: id, in: indexName)
    }

    public func deleteDocument(id: String, from indexName: String) -> EventLoopFuture<ESDeleteDocumentResponse> {
        self.elasticSearchClient.deleteDocument(id: id, from: indexName)
    }

    public func searchDocuments<Document: Decodable>(from indexName: String, searchTerm: String, type: Document.Type = Document.self) -> EventLoopFuture<ESGetMultipleDocumentsResponse<Document>> {
        self.elasticSearchClient.searchDocuments(from: indexName, searchTerm: searchTerm, type: type)
    }

    public func searchDocumentsCount(from indexName: String, searchTerm: String?) -> EventLoopFuture<ESCountResponse> {
        self.elasticSearchClient.searchDocumentsCount(from: indexName, searchTerm: searchTerm)
    }

    public func searchDocumentsPaginated<Document: Decodable>(from indexName: String, searchTerm: String, size: Int = 10, offset: Int = 0, type: Document.Type = Document.self) -> EventLoopFuture<ESGetMultipleDocumentsResponse<Document>> {
        self.elasticSearchClient.searchDocumentsPaginated(from: indexName, searchTerm: searchTerm, size: size, offset: offset, type: type)
    }

    public func searchDocumentsCount<Query: Encodable>(from indexName: String, query: Query) -> EventLoopFuture<ESCountResponse> {
        self.elasticSearchClient.searchDocumentsCount(from: indexName, query: query)
    }


    public func searchDocumentsPaginated<Document: Decodable, QueryBody: Encodable>(from indexName: String, queryBody: QueryBody, size: Int = 10, offset: Int = 0, type: Document.Type = Document.self) -> EventLoopFuture<ESGetMultipleDocumentsResponse<Document>> {
        self.elasticSearchClient.searchDocumentsPaginated(from: indexName, queryBody: queryBody, size: size, offset: offset, type: type)
    }

    public func customSearch<Document: Decodable, Query: Encodable>(from indexName: String, query: Query, type: Document.Type = Document.self) -> EventLoopFuture<ESGetMultipleDocumentsResponse<Document>> {
        self.elasticSearchClient.customSearch(from: indexName, query: query, type: type)
    }

    public func deleteIndex(_ name: String) -> EventLoopFuture<ESDeleteIndexResponse> {
        self.elasticSearchClient.deleteIndex(name)
    }

    public func checkIndexExists(_ name: String) -> EventLoopFuture<Bool> {
        self.elasticSearchClient.checkIndexExists(name)
    }

    public func customRequest(path: String, method: HTTPMethod, headers: HTTPHeaders = .init(), body: ByteBuffer?, queryItems: [URLQueryItem] = []) -> EventLoopFuture<HTTPClient.Response> {
        self.elasticSearchClient.customRequest(path: path, method: method, headers: headers, body: body, queryItems: queryItems)
    }
}
