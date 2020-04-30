//
//  Snapshot+Data.swift
//  Journal
//
//  Created by Kerby Jean on 4/30/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import FirebaseDatabase

// Turn DataSnapshot into JsonData
extension DataSnapshot {
    var data: Data? {
        guard let value = value else { return nil }
        return try? JSONSerialization.data(withJSONObject: value)
    }
    var json: String? {
        data?.string
    }
}

extension Data {
    var string: String? {
        String(data: self, encoding: .utf8)
    }
}
