//
//  CodeBefore.swift
//  TextParser
//
//  Created by Weerawut Chaiyasomboon on 20/11/2567 BE.
//

//
//  main.swift
//  TextParser
//
//  Created by Weerawut Chaiyasomboon on 20/11/2567 BE.
//

//import Foundation
//import NaturalLanguage
//
//
//@main
//struct App{
//    static func main(){
//        let text = CommandLine.arguments.dropFirst().joined(separator: " ")
//        print(text)
//        
//        print()
//        let language = NLLanguageRecognizer.dominantLanguage(for: text) ?? .undetermined
//        print("Detected language: \(language.rawValue)")
//        
//        print()
//        let sentiment = sentiment(for: text)
//        print("Sentiment analysis: \(sentiment)")
//        
//        let lemma = lemmatize(for: text)
//        print()
//        print("Found the following alternatives:")
//        for word in lemma{ //text.components(separatedBy: " ")
//            let embeddings = embeddings(for: word)
//            print("\t\(word): ", embeddings.formatted(.list(type: .and)))
//        }
//        
//        let entities = entities(for: text)
//        print()
//        print("Found the following entities:")
//        for entity in entities{
//            print("\t", entity)
//        }
//    }
//    
//    //Sentiment analysis
//    //-1 very negative, 1 very positive
//    static func sentiment(for string: String) -> Double{
//        let tagger = NLTagger(tagSchemes: [.sentimentScore])
//        tagger.string = string
//        let (sentiment, _) = tagger.tag(at: string.startIndex, unit: .paragraph, scheme: .sentimentScore)
//        
//        return Double(sentiment?.rawValue ?? "0") ?? 0
//    }
//    
//    //Word Embeddings
//    static func embeddings(for word: String) -> [String]{
//        var results = [String]()
//        if let embedding = NLEmbedding.wordEmbedding(for: .english){
//            let similarWords = embedding.neighbors(for: word, maximumCount: 10) //return [(String, NLDistance)]
//            for word in similarWords{
//                results.append("\(word.0) has a distance of \(word.1)")
//            }
//        }
//        
//        return results
//    }
//    
//    //Lemmatization
//    static func lemmatize(for string: String) -> [String]{
//        let tagger = NLTagger(tagSchemes: [.lemma])
//        tagger.string = string
//        
//        var results = [String]()
//        tagger.enumerateTags(in: string.startIndex..<string.endIndex, unit: .word, scheme: .lemma) { tag, range in
//            let stemForm = tag?.rawValue ?? String(string[range]).trimmingCharacters(in: .whitespaces)
//            if stemForm.isEmpty == false{
//                results.append(stemForm)
//            }
//            return true
//        }
//        
//        return results
//    }
//    
//    //Detect names, places, etc. in text
//    static func entities(for string: String) -> [String]{
//        let tagger = NLTagger(tagSchemes: [.nameType])
//        tagger.string = string
//        
//        var results = [String]()
//        tagger.enumerateTags(in: string.startIndex..<string.endIndex, unit: .word, scheme: .nameType, options: .joinNames) { tag, range in
//            guard let tag else { return true}
//            let match = String(string[range])
//            switch tag {
//            case .organizationName:
//                results.append("Organization: \(match)")
//            case .personalName:
//                results.append("Person: \(match)")
//            case .placeName:
//                results.append("Place: \(match)")
//            default:
//                break
//            }
//            return true
//        }
//        
//        return results
//    }
//}
//
