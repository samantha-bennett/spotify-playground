//
//  NetworkManager.swift
//  SpotifyTestApp
//
//  Created by Samantha Bennett on 12/11/22.
//

import Foundation
import OSLog
import UIKit.UIImage

class NetworkManager {
    public static var shared: NetworkManager = {
        NetworkManager()
    }()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: NetworkManager.self))

    private var cachedSession: URLSession?
    private var urlSession: URLSession? {
        get async {
            if let cachedSession {
                return cachedSession
            }
            guard let token = await token else { return nil }
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.httpAdditionalHeaders = ["Content-Type": "application/json",
                                                          "Authorization": "Bearer \(token)" ]
            cachedSession = URLSession(configuration: sessionConfiguration)
            return cachedSession
        }
    }

    private var cachedToken: String?
    private var token: String? {
        get async {
            if let cachedToken {
                return cachedToken
            }

            cachedToken = await fetchToken()
            return cachedToken
        }
    }


    private init() {
    }

    private func isValidResponse(_ response: URLResponse) throws -> Bool {
        guard let httpResponse = response as? HTTPURLResponse else { return false }
        guard httpResponse.statusCode == 200 else {
            logger.error("Network error: \(httpResponse)")
            // throw?
            throw SpotifyError.network
        }

        return true
    }
}

// Authentication
extension NetworkManager {

    enum NetworkError: Error {
        case authorization
    }

    func fetchToken() async -> String? {

        struct TokenResponse: Decodable {
            let accessToken: String
            let tokenType: String
            let expiresIn: Int
        }

        func createRequest() -> URLRequest? {
            let url = URL(string: "https://accounts.spotify.com/api/token")
            var request = URLRequest(url: url!)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(APIKeys.SpotifyAuthKey, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            let post = "grant_type=client_credentials"
            let postData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)!
            request.httpBody = postData
            return request
        }

        do {
            guard let request = createRequest() else { return nil }
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else { return nil }
            guard httpResponse.statusCode == 200 else {
                logger.error("Failed to get token for \(request.debugDescription). \n \(httpResponse).")
                throw NetworkError.authorization
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let tokenData = try decoder.decode(TokenResponse.self, from: data)
            return tokenData.accessToken
        } catch {
            logger.error("Failed to get token. Error: \(error)")
        }
        return nil
    }
}

extension NetworkManager {
    func availableMarkets() async throws -> [String]? {
        struct Markets: Decodable {
            let markets: [String]
        }
        let string = "https://api.spotify.com/v1/markets"
        let urlRequest = URL(string: string).flatMap { URLRequest(url: $0) }
        guard let urlRequest else { return nil }
        
        do {
            guard let urlSession = await urlSession else { return nil }
            let (data, response) = try await urlSession.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else { return nil }
            guard httpResponse.statusCode == 200 else {
                logger.error("Failed to fetch url \(string). Response: \(response)")
                throw NetworkError.authorization
            }
            let decoder = JSONDecoder()
            let markets = try decoder.decode(Markets.self, from: data)
            return markets.markets
        } catch {
            logger.error("Error getting markets \(error)")
        }
        return nil
    }
}

extension NetworkManager {
    enum SpotifyError: Error {
        case authentication
        case network
        case decoding
    }

    func albums(offset: Int = 0) async throws -> [Album]? {
        struct AlbumsResponse: Decodable {
            let items: [Album]
        }

        let string = "https://api.spotify.com/v1/browse/new-releases"
        guard var components = URLComponents(string: string) else { return nil }
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(50)),
            URLQueryItem(name: "country", value: "US"),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        let request = components.url.flatMap { URLRequest(url: $0) }

        guard let request else { return nil }

        // throw?
        guard let session = await urlSession else {
            throw SpotifyError.authentication
        }

        let (data, response) = try await session.data(for: request)

        guard try isValidResponse(response) else { return nil }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let results = try decoder.decode([String: AlbumsResponse].self, from: data)
            return results["albums"]?.items
        } catch {
            logger.error("Error decoding album data \(error)")
            throw SpotifyError.decoding
        }
    }
}

extension NetworkManager {
    public func loadImage(url: URL) async -> UIImage? {
        let request = URLRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard try isValidResponse(response) else {
                return nil                
            }

            let image = UIImage(data: data)
            return image
        } catch {
            logger.error("Error fetching image \(error)")
        }
        return nil
    }
}
