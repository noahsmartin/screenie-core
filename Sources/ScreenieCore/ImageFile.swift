//
//  ImageFile.swift
//  ScreenieCore
//
//  Created by Noah Martin on 1/20/20.
//  Copyright © 2020 Noah Martin. All rights reserved.
//

import Foundation

public protocol ImageFile {
  var url: URL { get }
  var cacheKey: String { get }
}
