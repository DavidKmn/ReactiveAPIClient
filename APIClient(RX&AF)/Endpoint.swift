//
//  Endpoint.swift
//  APIClient(RX&AF)
//
//  Created by David on 23/05/2018.
//  Copyright © 2018 David. All rights reserved.
//

import Foundation

typealias Parameters = [String: Any]
typealias Path = String

enum Method {
    case get, post, put, patch, delete
}

final class Endpoint<Response> {
    let method: Method
    let path: Path
    let parameters: Parameters?
    let decode: (Data) throws -> Response
    
    init(method: Method = .get, path: Path, parameters: Parameters? = nil, decode: @escaping (Data) throws -> Response) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.decode = decode
    }
}

extension Endpoint where Response: Decodable {
    convenience init(method: Method = .get, path: Path, parameters: Parameters? = nil) {
        self.init(method: method, path: path, parameters: parameters) {
            try JSONDecoder().decode(Response.self, from: $0)
        }
    }
}

extension Endpoint where Response == Void {
    convenience init(method: Method = .get, path: Path, parameters: Parameters? = nil) {
        self.init(method: method, path: path, parameters: parameters, decode: { _ in () })
    }
}
