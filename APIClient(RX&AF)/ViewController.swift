//
//  ViewController.swift
//  APIClient(RX&AF)
//
//  Created by David on 23/05/2018.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit

// In general, the actual net network calls are only made from Model layer (e.g. API.Customer would only be used directly inside CustomerService class)

struct Customer: Decodable {
    let firstName: String
}

enum API {}

extension API {
    static func getCustomer() -> Endpoint<Customer> {
        return Endpoint(path: "customer/profile")
    }
    
    static func patchCustomer(firstName: String) -> Endpoint<Customer> {
        return Endpoint(method: .patch, path: "customer/profile", parameters: ["firstName" : firstName])
    }
}

extension API {
    static func postFeedback(email: String, message: String) -> AuthorizedEndpoint<Scope.Salesman, Void> {
        return AuthorizedEndpoint(
            raw: Endpoint(
                method: .post,
                path: "/feedback",
                parameters: ["email": email,
                             "message": message]
            )
        )
    }
    
    static func getCustomer() -> AuthorizedEndpoint<Scope.Customer, Customer> {
        return AuthorizedEndpoint(
            raw: Endpoint(path: "/customer/profile")
        )
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        let client = NetworkClient(accessToken: "access-token")
//        client.request(API.getCustomer())
//        client.request(API.patchCustomer(firstName: "David"))

        let accessToken = "customer_auth_token"
        let client = AuthorizedClient<Scope.Salesman>(raw: NetworkClient(accessToken: accessToken))
        
        // This line gets compiled successfully.
        _ = client.request(API.postFeedback(email: "email", message: "message"))
        
        // And this doesn't.
//        _ = client.request(API.getCustomer())
    }
}




