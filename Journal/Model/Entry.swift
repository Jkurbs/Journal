//
//  Entry.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import Foundation

class Entry: NSCoder {
    
    var url: String!
    var text: String!
    var sentiment: String?
    var date: String!
    var thumbnail: Data!
    
    init(url: String, text: String, sentiment: String, date: String, thumbnail: Data) {
        self.url = url
        self.text = text
        self.sentiment = sentiment
        self.date = date
        self.thumbnail = thumbnail
    }
}
