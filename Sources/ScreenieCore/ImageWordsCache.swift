//
//  ImageWordsCache.swift
//  ScreenieCore
//
//  Created by Noah Martin on 1/20/20.
//  Copyright © 2020 Noah Martin. All rights reserved.
//

import Foundation

public final class ImageWordsCache {
  public static let shared = ImageWordsCache()

  init?() {
    if let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
      self.cacheFile = directory.appendingPathComponent("imageTagCache")
    } else {
      return nil
    }
    cacheSize = 0

    cacheQueue.async(flags: .barrier) {
      if let data = try? Data(contentsOf: self.cacheFile) {
        self.cacheSize = data.count
        self.cache = try? JSONDecoder().decode(Cache.self, from: data)
      } else {
        self.cacheSize = 0
      }
    }
  }

  public private(set) var cacheSize: Int

  public func readFromCache(screenshot: ImageFile) -> [String]? {
    let cacheID = screenshot.cacheKey
    return cacheQueue.sync {
      return self.cache?.items[cacheID]?.words
    }
  }

  public func writeToCache(screenshot: ImageFile, words: [String]) {
    let cacheID = screenshot.cacheKey
    if cache == nil {
      cache = Cache(items: [:])
    }
    cacheQueue.async(flags: .barrier) {
      self.cache?.items[cacheID] = CacheItem(words: words)
      if let data = try? self.encoder.encode(self.cache) {
        self.cacheSize = data.count
        try? data.write(to: self.cacheFile)
      }
    }
  }

  public func clear(completion: @escaping () -> Void) {
    cacheQueue.async(flags: .barrier) {
      self.cache = nil
      self.cacheSize = 0
      try? FileManager.default.removeItem(at: self.cacheFile)
      DispatchQueue.main.async {
        completion()
      }
    }
  }

  private let cacheFile: URL
  private var cache: Cache?
  private let encoder = JSONEncoder()
  private let cacheQueue = DispatchQueue(label: "com.thnkdev.screenie.cache_queue", qos: .userInitiated, attributes: .concurrent)
}

struct Cache: Codable {
  var items: [String: CacheItem]
}

struct CacheItem: Codable {
  let words: [String]
}
