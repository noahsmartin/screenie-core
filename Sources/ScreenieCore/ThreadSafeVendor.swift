//
//  ThreadSafeVendor.swift
//  QuickShot
//
//  Created by Noah Martin on 12/7/19.
//  Copyright © 2019 Noah Martin. All rights reserved.
//

import Foundation

public final class ThreadSafeVendor<ObjectType> {
  public init(maxItems: Int, vendor: @escaping () -> ObjectType) {
    self.vendor = vendor
    for _ in 0..<maxItems {
      list.append(ItemWrapper(item: vendor()))
    }
  }

  public func vend(_ work: (ObjectType) -> Void) {
    var object: ItemWrapper? = nil
    accessQueue.sync {
      for item in list {
        if item.available {
          object = item
          item.available = false
          break
        }
      }
    }
    if let object = object {
      work(object.item)
      object.available = true
    } else {
      assertionFailure("Unexpected nil item")
    }
  }

  private var list = [ItemWrapper]()
  private let vendor: () -> ObjectType

  private let accessQueue = DispatchQueue(label: "accessQueue")

  final class ItemWrapper {
    init(item: ObjectType) {
      self.item = item
      available = true
    }

    let item: ObjectType
    var available: Bool
  }
}
