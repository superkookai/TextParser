//
//  main.swift
//  TextParser
//
//  Created by Weerawut Chaiyasomboon on 20/11/2567 BE.
//

import Foundation
import NaturalLanguage
import ArgumentParser

@main
struct App: ParsableCommand{
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "analyze", abstract: "Analyzes input text using a range of natural language approaches.")
    }
    
    @Argument(help: "The text you want to analyze")
    var input: [String]
    
    @Flag(name: .shortAndLong, help: "Show detected language.")
    var detectLanguage = false

    @Flag(name: .shortAndLong, help: "Prints how positive or negative the input is.")
    var sentimentAnalysis = false

    @Flag(name: .shortAndLong, help: "Shows the stem form of each word in the input.")
    var lemmatize = false
    
    @Flag(name: .shortAndLong, help: "Prints alternative words for each word in the input.")
    var alternatives = false

    @Flag(name: .shortAndLong, help: "Prints names of people, places, and organizations in the input.")
    var names = false
    
    @Flag(name: .shortAndLong, help: "Use all options to analyze the input.")
    var everything = false
    
    @Option(name: .shortAndLong, help: "The maximum number of alternatives to suggest")
    var maximumAlternatives = 10
    
    mutating func run(){
        if everything {
            detectLanguage = true
            sentimentAnalysis = true
            lemmatize = true
            alternatives = true
            names = true
        }
        
        let text = input.joined(separator: " ")
        print(text)
        
        if detectLanguage{
            print()
            let language = NLLanguageRecognizer.dominantLanguage(for: text) ?? .undetermined
            print("Detected language: \(language.rawValue)")
        }
        
        if sentimentAnalysis{
            print()
            let sentiment = sentiment(for: text)
            print("Sentiment analysis: \(sentiment)")
        }
        
        lazy var lemma = lemmatize(for: text)
        if lemmatize{
            print()
            print("Found the following lemma:")
            print("\t", lemma.formatted(.list(type: .and)))
        }
        
        if alternatives{
            print()
            print("Found the following alternatives:")
            for word in lemma{ //text.components(separatedBy: " ")
                let embeddings = embeddings(for: word)
                print("\t\(word): ", embeddings.formatted(.list(type: .and)))
            }
        }
        
        if names{
            let entities = entities(for: text)
            print()
            print("Found the following entities:")
            for entity in entities{
                print("\t", entity)
            }
        }
    }
    
    //Sentiment analysis
    //-1 very negative, 1 very positive
    func sentiment(for string: String) -> Double{
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = string
        let (sentiment, _) = tagger.tag(at: string.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        return Double(sentiment?.rawValue ?? "0") ?? 0
    }
    
    //Word Embeddings
    func embeddings(for word: String) -> [String]{
        var results = [String]()
        if let embedding = NLEmbedding.wordEmbedding(for: .english){
            let similarWords = embedding.neighbors(for: word, maximumCount: maximumAlternatives) //return [(String, NLDistance)]
            for word in similarWords{
                results.append("\(word.0) has a distance of \(word.1)")
            }
        }
        
        return results
    }
    
    //Lemmatization
    func lemmatize(for string: String) -> [String]{
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = string
        
        var results = [String]()
        tagger.enumerateTags(in: string.startIndex..<string.endIndex, unit: .word, scheme: .lemma) { tag, range in
            let stemForm = tag?.rawValue ?? String(string[range]).trimmingCharacters(in: .whitespaces)
            if stemForm.isEmpty == false{
                results.append(stemForm)
            }
            return true
        }
        
        return results
    }
    
    //Detect names, places, etc. in text
    func entities(for string: String) -> [String]{
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = string
        
        var results = [String]()
        tagger.enumerateTags(in: string.startIndex..<string.endIndex, unit: .word, scheme: .nameType, options: .joinNames) { tag, range in
            guard let tag else { return true}
            let match = String(string[range])
            switch tag {
            case .organizationName:
                results.append("Organization: \(match)")
            case .personalName:
                results.append("Person: \(match)")
            case .placeName:
                results.append("Place: \(match)")
            default:
                break
            }
            return true
        }
        
        return results
    }
}

