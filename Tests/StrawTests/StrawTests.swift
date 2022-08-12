import XCTest
@testable import Straw

import Datable

final class StrawTests: XCTestCase {
    func testRead() throws
    {
        let input = "test".data
        let correct = input

        Task
        {
            let straw = Straw()
            await straw.write(input)
            let result = try await straw.read()

            XCTAssertEqual(result.string, correct.string)
        }
    }

    func testRead2() throws
    {
        let input = "test".data
        let correct = "testtest".data

        Task
        {
            let straw = Straw()
            await straw.write(input)
            await straw.write(input)
            let result = try await straw.read()

            XCTAssertEqual(result.string, correct.string)
        }
    }

    func testReadChunks() throws
    {
        let input = "test".data
        let correct = [input, input]

        Task
        {
            let straw = Straw()
            await straw.write(input)
            await straw.write(input)
            let result = try await straw.readAllChunks()

            XCTAssertEqual(result, correct)
        }
    }

    func testReadSize() throws
    {
        let input = "test".data
        let correct = "t".data

        Task
        {
            let straw = Straw()
            await straw.write(input)
            await straw.write(input)
            let result = try await straw.read(size: 1)

            XCTAssertEqual(result.string, correct.string)
        }
    }

    func testReadSize2() throws
    {
        let input = "test".data
        let correct = "testt".data

        Task
        {
            let straw = Straw()
            await straw.write(input)
            await straw.write(input)
            let result = try await straw.read(size: 5)

            XCTAssertEqual(result.string, correct.string)
        }
    }

    func testReadMaxSize() throws
    {
        let input = "test".data
        let correct = "testtest".data

        Task
        {
            let straw = Straw()
            await straw.write(input)
            await straw.write(input)
            let result = try await straw.read(maxSize: 10)

            XCTAssertEqual(result.string, correct.string)
        }
    }
}
