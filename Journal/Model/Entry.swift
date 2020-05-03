//
//  Entry.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import IGListKit
import Foundation

class Entry: Codable {
    
    var imageUrl: String?
    var name: String!
    var speech: String!
    var sentiment: String?
    var sentimentScore: Double?
    var date: String!
    
    init(name: String, speech: String, sentiment: String, sentimentScore: Double, date: String, imageUrl: String? = "") {
        self.name = name
        self.speech = speech
        self.sentiment = sentiment
        self.sentimentScore = sentimentScore
        self.date = date
        self.imageUrl = imageUrl
    }
}

extension Entry: Equatable {
    
    public static func ==(rhs: Entry, lhs: Entry) -> Bool {
        rhs.name != lhs.name
    }
}

extension Entry: ListDiffable {
    
    public func diffIdentifier() -> NSObjectProtocol {
        name as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? Entry else { return false }
        return self.name == object.name
    }
}

