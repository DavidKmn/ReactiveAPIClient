//
//  Client.swift
//  APIClient(RX&AF)
//
//  Created by David on 23/05/2018.
//  Copyright © 2018 David. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift


protocol ClientProtocol {
    func request<Response>(_ endpoint: Endpoint<Response>) -> Single<Response>
}

final class NetworkClient: ClientProtocol {
    private let manager: Alamofire.SessionManager
    private let baseURL = URL(string: "base-url-goes-here")!
    private let queue = DispatchQueue(label: "queue-label-here")
    
    init(accessToken: String) {
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["Authorization"] = "Bearer \(accessToken)"
        
        let configuration = URLSessionConfiguration.default
        
        // Add 'Auth' header to the default HTTP headers set by AF
        configuration.httpAdditionalHeaders = defaultHeaders
        
        self.manager = Alamofire.SessionManager(configuration: configuration)
        let retrier = OAuth2Retrier()
        self.manager.retrier = retrier
    }
    
    func request<Response>(_ endpoint: Endpoint<Response>) -> Single<Response> {
        return Single<Response>.create { observer in
            let request = self.manager.request(
                self.url(path: endpoint.path),
                method: self.httpMethod(from: endpoint.method),
                parameters: endpoint.parameters
            )
            
            request
            .validate()
                .downloadProgress(closure: { (progress) in
                    print("totalUnitCount:\n", progress.totalUnitCount)
                    print("completedUnitCount:\n", progress.completedUnitCount)
                    print("fractionCompleted:\n", progress.fractionCompleted)
                    print("localizedDescription:\n", progress.localizedDescription)
                    print("--------------------------------")
                })
                .responseData(queue: self.queue, completionHandler: { (response) in
                    let result = response.result.flatMap(endpoint.decode)
                    switch result {
                    case .success(let value): observer(.success(value))
                    case .failure(let error): observer(.error(error))
                    }
                })
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    private func url(path: Path) -> URL {
        return baseURL.appendingPathComponent(path)
    }
    
    private func httpMethod(from method: Method) -> Alamofire.HTTPMethod {
        switch method {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .patch: return .patch
        case .delete: return .delete
        }
    }
    
}

private class OAuth2Retrier: Alamofire.RequestRetrier {
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if (error as? AFError)?.responseCode == 401 {
            // Implement Auth2 refresh flow
            // See https://github.com/Alamofire/Alamofire#adapting-and-retrying-requests
        }
        completion(false, 0)
    }
}












