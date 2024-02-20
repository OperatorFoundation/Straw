//
//  AsyncStraw.swift
//
//
//  Created by Dr. Brandon Wiley on 9/4/23.
//

import Foundation
import Logging

// A variant of Straw for when you don't need thread safety
public actor AsyncStraw
{
    let logger: Logger?

    public var count: Int
    {
        return self.buffer.count
    }

    public var isEmpty: Bool
    {
        return self.count == 0
    }

    var buffer: Data = Data()

    public init(_ logger: Logger? = nil)
    {
        self.logger = logger
    }

    public func write(_ chunk: Data)
    {
        self.buffer.append(chunk)
    }

    public func write(_ chunks: [Data])
    {
        for chunk in chunks
        {
            self.write(chunk)
        }
    }

    public func read() throws -> Data
    {
        let result = self.buffer
        self.buffer = Data()
        return result
    }

    public func readAllChunks() throws -> [Data]
    {
        let result = try self.read()
        if result.isEmpty
        {
            return []
        }
        else
        {
            return [result]
        }
    }

    public func readAllData() throws -> Data
    {
        return try self.read()
    }

    public func peekAllData() throws -> Data
    {
        return self.buffer
    }

    public func read(size: Int) throws -> Data
    {
        self.logger?.trace("UnsafeStraw.read(size: \(size))")

        guard size > 0 else
        {
            return Data()
        }

        guard !self.buffer.isEmpty else
        {
            return Data()
        }

        guard self.count >= size else
        {
            throw StrawError.notEnoughBytes(size, self.count)
        }

        let result = Data(self.buffer[..<size])
        self.buffer = Data(self.buffer[size...])

        return result
    }

    public func peek(size: Int) throws -> Data
    {
        guard size > 0 else
        {
            return Data()
        }

        guard !self.buffer.isEmpty else
        {
            return Data()
        }

        guard self.count >= size else
        {
            throw StrawError.notEnoughBytes(size, self.count)
        }

        let result = Data(self.buffer[...size])

        return result
    }

    public func peek(offset: Int, size: Int) throws -> Data
    {
        guard size > 0 else
        {
            return Data()
        }

        guard !self.buffer.isEmpty else
        {
            return Data()
        }

        guard self.count >= size else
        {
            throw StrawError.notEnoughBytes(size, self.count)
        }

        let result = Data(self.buffer[offset..<offset+size])

        return result
    }

    public func read(maxSize: Int) throws -> Data
    {
        guard maxSize > 0 else
        {
            return Data()
        }

        if self.buffer.isEmpty
        {
            return Data()
        }

        let size = min(maxSize, self.buffer.count)
        return try self.read(size: size)
    }

    public func peek(maxSize: Int) throws -> Data
    {
        guard maxSize > 0 else
        {
            return Data()
        }

        if self.buffer.isEmpty
        {
            return Data()
        }

        let size = min(maxSize, self.buffer.count)
        return try self.peek(size: size)
    }

    public func clear(_ size: Int) throws
    {
        let _ = try self.read(size: size)
    }
}
