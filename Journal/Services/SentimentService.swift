//
//  SentimentService.swift
//  Journal
//
//  Created by Kerby Jean on 4/30/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//


import NaturalLanguage

class AI {
    
    static let shared = AI()
    
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    
    func sentimentAnalysis(string: String) -> (sentiment: String, score: Double) {
        
        tagger.string = string
        
        let (sentiment, _) = tagger.tag(at: string.startIndex, unit: .paragraph, scheme: .sentimentScore)

        if let score = Double(sentiment?.rawValue ?? "") {
            if score < 0 {
                return (sentiment: "", score: score)
            } else if score > 0 {
                return (sentiment: "", score: score)
            } else {
                return (sentiment: "", score: score)
            }
        }
        return (sentiment: "Neutral", score: 0.0)
    }
}
