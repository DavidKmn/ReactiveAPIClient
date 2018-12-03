//
//  PhantomTypes.swift
//  APIClient(RX&AF)
//
//  Created by David on 23/05/2018.
//  Copyright © 2018 David. All rights reserved.
//

import Foundation
import RxSwift

struct Scope {
    enum Salesman {}
    enum Customer {}
}

struct AuthorizedEndpoint<Authorization, Response> {
    fileprivate let raw: Endpoint<Response>
    init(raw: Endpoint<Response>) { self.raw = raw }
}

struct AuthorizedClient<Authorization> {
    fileprivate let raw: ClientProtocol
    init(raw: ClientProtocol) { self.raw = raw }
}

extension AuthorizedClient where Authorization == Scope.Salesman {
    func request<Response>(_ endpoint: AuthorizedEndpoint<Scope.Salesman, Response>) -> Single<Response> {
        return raw.request(endpoint.raw)
    }
}

extension AuthorizedClient where Authorization == Scope.Customer {
    func request<Response>(_ endpoint: AuthorizedEndpoint<Scope.Salesman, Response>) -> Single<Response> {
        return raw.request(endpoint.raw)
    }
    func request<Response>(_ endpoint: AuthorizedEndpoint<Scope.Customer, Response>) -> Single<Response> {
        return raw.request(endpoint.raw)
    }
}







