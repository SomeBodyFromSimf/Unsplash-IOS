//
//  Networking.swift
//  StudyProject
//
//  Created by Чистоусов Михаил on 20.08.2026.
//

import Foundation

nonisolated enum NetworkError: Error {
    case invalidResponse
    case unacceptableStatusCode(Int)
}

public nonisolated protocol HTTPTransport: Sendable {
    func data(from: URLRequest) async throws -> (Data, URLResponse)
}

public nonisolated final class URLSessionHTTPTransport: HTTPTransport {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func data(from request: URLRequest) async throws -> (Data, URLResponse) {
        return try await self.session.data(for: request)
    }
}

public nonisolated final class APIClient: Sendable {
    
    private let transport: any HTTPTransport
    private let decoder: JSONDecoder
    
    public init(
        transport: any HTTPTransport,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.transport = transport
        self.decoder = decoder
    }
    
    func get<Response: Decodable>(
        _ type: Response.Type,
        from request: URLRequest
    ) async throws -> Response {
        let (data, response) = try await transport.data(from: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.unacceptableStatusCode(httpResponse.statusCode)
        }
        return try decoder.decode(type, from: data)
    }
}
