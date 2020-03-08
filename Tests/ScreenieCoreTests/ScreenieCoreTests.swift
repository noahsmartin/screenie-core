import Combine
import NaturalLanguage
import XCTest
@testable import ScreenieCore

final class ScreenieCoreTests: XCTestCase {
    func testAddItem() {
      let item = TestIndexItem(string: "test")
      let queue = DispatchQueue(label: "testAccessQueue")
      let indexer = Indexer<TestIndexItem>(speed: .standard, progressQueue: DispatchQueue.main, accesQueue: queue)
      let exp = expectation(description: "finished indexing")
      indexer.indexItems(diff: CollectionDifference<TestIndexItem>([CollectionDifference<TestIndexItem>.Change.insert(offset: 0, element: item, associatedWith: nil)])!, completion: { _ in })
      cancellable = indexer.$isFinished.sink { [weak self] finished in
        guard finished && self?.cancellable != nil else { return }

        self?.cancellable = nil
        queue.async {
          exp.fulfill()
        }
      }
      wait(for: [exp], timeout: 10)
      let result = indexer.query(string: "Test")
      XCTAssertEqual(result.first, item)
    }

  var cancellable: Cancellable?

    static var allTests = [
        ("testExample", testAddItem),
    ]
}

struct TestIndexItem: IndexItem {
  let string: String

  func getSearchableRepresentation(
    indexContext: IndexContext,
    tokenizer: NLTokenizer,
    progressHandler: @escaping (Double) -> Void,
    completion: @escaping (SearchableRepresentation) -> Void)
  {
    progressHandler(1.0)
    completion(SearchableRepresentation(text: [[Text(string: string, confidence: 1.0)]], dates: Set<Date>()))
  }
}
