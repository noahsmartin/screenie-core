//
//  String+NLP.swift
//  QuickShot
//
//  Created by Noah Martin on 7/6/19.
//  Copyright © 2019 Noah Martin. All rights reserved.
//

import Foundation
import NaturalLanguage

extension String {

  func lemmas(tagger: NLTagger) -> [String] {
    tagger.string = self.lowercased()
    var result = [String: Bool]()
    tagger.enumerateTags(in: tagger.string!.startIndex..<tagger.string!.endIndex, unit: .word, scheme: .lemma, options: [.omitOther, .omitPunctuation, .omitWhitespace]) { tag, range -> Bool in
      if let substring = tagger.string?[range] {
        let originalWord = String(substring)
        result[originalWord] = true
        if let lemma = tag?.rawValue {
          result[lemma] = true
        }
      }
      return true
    }
    return Array(result.keys)
  }

  func lemma(tagger: NLTagger) -> String {
    tagger.string = self
    var result: String?
    tagger.enumerateTags(in: tagger.string!.startIndex..<tagger.string!.endIndex, unit: .word, scheme: .lemma, options: .init()) { tag, _ in
      result = tag?.rawValue
      return true
    }
    return result ?? self
  }
}
