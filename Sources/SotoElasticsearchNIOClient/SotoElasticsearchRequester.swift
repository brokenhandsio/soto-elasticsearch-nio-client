import AsyncHTTPClient
import Elasticsearch
import Foundation
import HTTPTypes
import Logging
import SotoCore
import SotoElasticsearchService

struct SotoElasticsearchRequester: ElasticsearchRequester {
    let awsClient: AWSClient
    let region: Region?
    let logger: Logger
    let client: HTTPClient

    func executeRequest(
        url urlString: String,
        method: HTTPRequest.Method,
        headers: HTTPFields,
        body: HTTPClientRequest.Body?
    ) async throws -> HTTPClientResponse {
        let es = ElasticsearchService(client: awsClient, region: self.region)
        guard let url = URL(string: urlString) else {
            throw ElasticsearchClientError(message: "Failed to convert \(urlString) to a URL", status: nil)
        }

        let awsBody =
            if let body = body {
                AWSHTTPBody(asyncSequence: body, length: nil)
            } else {
                AWSHTTPBody()
            }

        let httpMethod = HTTPMethod(rawValue: method.rawValue)

        var httpHeaders = HTTPHeaders()
        for header in headers {
            httpHeaders.add(name: header.name.canonicalName, value: header.value)
        }

        let headers = try await es.signHeaders(url: url, httpMethod: httpMethod, headers: httpHeaders, body: awsBody)

        var request = HTTPClientRequest(url: urlString)
        request.method = httpMethod
        request.headers = headers
        request.body = body

        self.logger.trace("Request: \(request)")

        return try await self.client.execute(request, timeout: .seconds(30))
    }
}
