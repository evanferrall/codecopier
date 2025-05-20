import SwiftUI
import XCTest
@testable import CodeCopierUI

final class PlaceholderTests: XCTestCase {
    func testAccentColor() {
        XCTAssertEqual(BrandColors.accent, Color(red: 0.11, green: 0.46, blue: 0.98))
    }
}
