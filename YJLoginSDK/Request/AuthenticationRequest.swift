//
//  AuthorizationRequest.swift
//  YJLoginSDK
//
//  © 2023 LY Corporation. All rights reserved.
//

import Foundation

internal struct AuthenticationRequest {

    var path: String = Constant.authorizationPath
    let clientId: String
    let codeChallenge: String
    let nonce: String
    let redirectUri: URL
    let responseType: ResponseType
    let scopes: [Scope]
    let state: String?
    var optionalParameter: OptionalParameters?
    var issuer: URL? = Constant.issuer

    var requestUrl: URL? {
        var parameters: [String: String] = [
            "client_id": clientId,
            "nonce": nonce,
            "redirect_uri": redirectUri.absoluteString,
            "response_type": responseType.rawValue,
            "scope": scopes.map {$0.rawValue}.joined(separator: " "),
            "code_challenge": codeChallenge,
            "code_challenge_method": "S256",
        ]

        if let state {
            parameters["state"] = state
        }

        if let optionalParameters = optionalParameter?.allParameters() {
            parameters.merge(optionalParameters) { (_, optionalParametersValue) in optionalParametersValue }
        }

        // swiftlint:disable:next force_unwrapping
        var authorizationUrlComponent = URLComponents(string: issuer!.absoluteString + path)!
        authorizationUrlComponent.queryItems = URLComponents.dictionaryToQueryItem(dic: parameters)
        return authorizationUrlComponent.formUrlencodedUrl
    }
}
