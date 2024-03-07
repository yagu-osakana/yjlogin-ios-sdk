//
//  AuthorizationResponse.swift
//  YJLoginSDK
//
//  © 2023 LY Corporation. All rights reserved.
//

import Foundation

internal struct AuthenticationResponse {
    let authorizationCode: String
    let state: String?

    internal init(url: URL, validatingWith expectedState: String? = nil) throws {
        guard let urlComponent = URLComponents(formUrlencodedString: url.absoluteString) else {
            throw AuthenticationResponseError.unexpectedError
        }

        var tmpCode: String?
        var state: String?
        var error: String?
        var errorDescription: String?
        var errorCode: Int?

        guard let queryItems = urlComponent.queryItems, !queryItems.isEmpty else {
            throw AuthenticationResponseError.userCancel
        }

        for item in queryItems {
            switch item.name {
            case "code":
                tmpCode = item.value
            case "state":
                state = item.value
            case "error":
                error = item.value
            case "error_description":
                errorDescription = item.value
            case "error_code":
                if let value = item.value, let intValue = Int(value) {
                    errorCode = intValue
                }
            default: break
            }
        }

        if state != nil && expectedState == nil {
            throw AuthenticationResponseError.invalidState
        }

        if state == nil && expectedState != nil {
            throw AuthenticationResponseError.invalidState
        }

        if state != nil && expectedState != nil {
            guard expectedState == state else {
                throw AuthenticationResponseError.invalidState
            }
        }

        if let error, let errorDescription, let errorCode {
            guard let responseError = AuthenticationResponseError.Error(rawValue: error) else {
                throw AuthenticationResponseError.undefinedError(error: error, description: errorDescription, code: errorCode)
            }

            throw AuthenticationResponseError.serverError(error: responseError, description: errorDescription, code: errorCode)
        }

        guard let unwrappedTmpCode = tmpCode else {
            throw AuthenticationResponseError.emptyAuthorizationCode
        }

        authorizationCode = unwrappedTmpCode
        self.state = state
    }
}
