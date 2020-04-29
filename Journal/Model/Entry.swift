//
//  Entry.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import Foundation

class Entry: NSCoder {
    
    var name: String!
    var speech: String!
    var sentiment: String?
    var date: Date!
    
    init(name: String, speech: String, sentiment: String, date: Date) {
        self.name = name
        self.speech = speech
        self.sentiment = sentiment
        self.date = date
    }
}
