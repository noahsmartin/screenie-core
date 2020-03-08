//
//  File.swift
//  
//
//  Created by Noah Martin on 1/20/20.
//

import Foundation
import Vision

public typealias WordProvider = (_ maxCandidates: Int, _ minConfidence: VNConfidence) -> [[Text]]

extension ImageFile {

  // This call will block until the completion handler is called
  public func findText(
    progressHandler: @escaping (Double) -> Void,
    completion: @escaping (WordProvider) -> Void)
  {
    var hasCalledCompletion: Bool = false
    let request = VNRecognizeTextRequest { request, error in
      guard let requestResults = request.results, error == nil else {
        hasCalledCompletion = true
        completion({_ , _ in []})
        return
      }

      guard let results = requestResults as? [VNRecognizedTextObservation] else {
        fatalError("Wrong result type")
      }

      let getWords = { maxCandidates, minConfidence in
        results.compactMap { observation in
          observation
            .topCandidates(maxCandidates)
            .filter({ $0.confidence >= minConfidence })
            .reduce([Text]()) { acc, text in
              acc + [Text(string: text.string, confidence: text.confidence)]
          }
        }
      }

      hasCalledCompletion = true
      completion(getWords)
    }
    request.preferBackgroundProcessing = true
    request.recognitionLanguages = ["en-US"]
    request.usesLanguageCorrection = true
    request.recognitionLevel = .accurate
    request.customWords = ["Screenie", "QuickRes", "ThnkDev"]
    request.progressHandler = { _, progress, _ in
      progressHandler(progress)
    }
    let requestHandler = VNImageRequestHandler(url: self.url)
    do {
      try requestHandler.perform([request])
    } catch {
      if !hasCalledCompletion {
        completion({_ , _ in []})
      }
    }
  }
}
