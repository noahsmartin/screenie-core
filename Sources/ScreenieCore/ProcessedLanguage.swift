//
//  ProcessedLanguage.swift
//  
//
//  Created by Noah Martin on 3/7/20.
//

import Foundation

// The language representation of an item in the index.
// Stored for debugging purposes
public struct ProcessedLanguage {
  // Output from OCR
  public let recognizedText: [[Text]]
  // Individual normalized words and their frequencies
  public let lemmas: [String: Int]
  // Original words when different from the lemmas
  public let originalWords: [String: Int]
}
