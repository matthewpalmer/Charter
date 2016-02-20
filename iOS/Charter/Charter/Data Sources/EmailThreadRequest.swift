//
//  EmailThreadRequest.swift
//  Charter
//
//  Created by Matthew Palmer on 21/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation

protocol EmailThreadRequest {
    var URLRequestQueryParameters: Dictionary<String, String> { get }
}
