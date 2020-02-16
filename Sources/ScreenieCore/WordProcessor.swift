//
//  File.swift
//  
//
//  Created by Noah Martin on 1/26/20.
//

import Foundation
import NaturalLanguage

public final class WordProcessor {
  public static func handleWords(
    foundWords: [String],
    tokenizer: NLTokenizer,
    indexContext: IndexContext) -> SearchableRepresentation
  {
    var strings = Set<String>()
    var foundDates = Set<Date>()
    for text in foundWords {
      // Get dates for this candidate
      let matches = indexContext.detector?.matches(in: text, options: [], range: NSMakeRange(0, text.utf16.count))
      let dates: [Date] = matches?.compactMap { $0.date } ?? []

      // Get words for this candidate
      let tokens = Set(text.tokenize(provided: tokenizer))
      let firstReplace =  tokens.filter { Int($0) == nil }.fixingCharacters(start: "0", end: "o")
      let secondReplace = tokens.fixingCharacters(start: "a", end: "o")
      let thirdReplace = tokens.fixingCharacters(start: "r", end: "n")
      let newStrings = (tokens + firstReplace + secondReplace + thirdReplace).map { $0.lowercased() }
      strings.formUnion(newStrings)
      foundDates.formUnion(dates)
    }
    return SearchableRepresentation(words: strings, dates: foundDates)
  }
}

extension Sequence where Element == String {
  func fixingCharacters(start: String, end: String) -> [String] {
    var results = [String]()
    for token in self {
      var replacing = token
      while let range = replacing.range(of: start) {
        replacing = replacing.replacingCharacters(in: range, with: end)
        results.append(replacing)
      }
    }
    return results
  }
}

extension String {
  func tokenize(provided: NLTokenizer) -> [String] {
    let tokenizer = provided
    tokenizer.string = self
    var results = [String]()
    tokenizer.enumerateTokens(in: tokenizer.string!.startIndex..<tokenizer.string!.endIndex) { range, _ in
      if let token = tokenizer.string?[range] {
        results.append(String(token))
      }
      return true
    }
    return results
  }
}
