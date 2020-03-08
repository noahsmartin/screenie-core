//
//  ScreenieCore.swift
//  ScreenieCore
//
//  Created by Noah Martin on 1/20/20.
//  Copyright © 2020 Noah Martin. All rights reserved.
//

import NaturalLanguage

public class IndexContext {
  public init() { }

  public let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
}

public struct Text: Codable, Hashable {
  public let string: String
  public let confidence: Float
}

public struct SearchableRepresentation {
  public init(text: [[Text]], dates: Set<Date>) {
    self.text = text
    self.dates = dates
  }

  public let text: [[Text]]
  public let dates: Set<Date>
}

public protocol IndexItem: Hashable {
  func getSearchableRepresentation(
    indexContext: IndexContext,
    tokenizer: NLTokenizer,
    progressHandler: @escaping (Double) -> Void,
    completion: @escaping (SearchableRepresentation) -> Void)
}

