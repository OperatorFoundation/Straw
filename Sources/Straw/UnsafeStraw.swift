//
//  UnsafeStraw.swift
//  
//
//  Created by Dr. Brandon Wiley on 9/4/23.
//

import Foundation
import Logging

// A variant of Straw for when you don't need thread safety
public class UnsafeStraw
{
    let logger: Logger?

    public var count: Int
    {
        return self.buffer.reduce(0) { $0 + $1.count }
    }

    public var isEmpty: Bool
    {
        return self.count == 0
    }

    var buffer: [Data] = []

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
        self.buffer.append(contentsOf: chunks)
    }

    public func read() throws -> Data
    {
        if self.buffer.isEmpty
        {
            return Data()
        }
        else
        {
            return self.buffer.removeFirst()
        }
    }

    public func readAllChunks() throws -> [Data]
    {
        if self.buffer.isEmpty
        {
            throw StrawError.bufferEmpty
        }

        let result = self.buffer
        self.buffer = []
        return result
    }

    public func readAllData() throws -> Data
    {
        if self.buffer.isEmpty
        {
            throw StrawError.bufferEmpty
        }

        var result = Data()
        for chunk in self.buffer
        {
            result.append(chunk)
        }

        self.buffer = []

        return result
    }

    public func peekAllData() throws -> Data
    {
        if self.buffer.isEmpty
        {
            throw StrawError.bufferEmpty
        }

        var result = Data()
        for chunk in self.buffer
        {
            result.append(chunk)
        }

        return result
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

        let count = self.buffer.reduce(0) { $0 + $1.count }
        guard count >= size else
        {
            throw StrawError.notEnoughBytes(size, count)
        }

        var result = Data()
        self.logger?.trace("UnsafeStraw.read(size:) - entering loop \(result.count) \(size) \(count) \(self.buffer.count)")
        while result.count < size, !self.buffer.isEmpty
        {
            self.logger?.trace("UnsafeStraw.read(size:) - in loop \(result.count) \(size) \(count) \(self.buffer.count)")

            var chunk = self.buffer.removeFirst()
            let bytesNeeded = size - result.count
            if chunk.count <= bytesNeeded
            {
                result.append(chunk)
            }
            else // chunk.count > bytesNeeded
            {
                let bytes = chunk[0..<bytesNeeded]
                result.append(bytes)
                chunk = chunk[bytesNeeded...]
                self.buffer.insert(chunk, at: 0)
            }

            self.logger?.trace("UnsafeStraw.read(size:) - end of loop \(result.count) \(size) \(count) \(self.buffer.count)")
        }

        self.logger?.trace("UnsafeStraw.read(size:) - exited loop \(result.count) \(size) \(count) \(self.buffer.count)")

        return result
    }

    public func peek(size: Int) throws -> Data
    {
        guard size > 0 else
        {
            return Data()
        }

        let count = self.buffer.reduce(0) { $0 + $1.count }
        guard count >= size else
        {
            throw StrawError.notEnoughBytes(size, count)
        }

        var result = Data()
        var index = 0
        while result.count < size && index < self.buffer.count
        {
            var chunk = self.buffer[index]

            let bytesNeeded = size - result.count
            if chunk.count <= bytesNeeded
            {
                result.append(chunk)
            }
            else // chunk.count > bytesNeeded
            {
                let bytes = chunk[0..<bytesNeeded]
                result.append(bytes)
                chunk = chunk[bytesNeeded...]
            }

            index = index + 1
        }

        return result
    }

    public func peek(offset: Int, size: Int) throws -> Data
    {
        let data = try self.peek(size: offset + size)
        return data[offset...]
    }

    public func read(maxSize: Int) throws -> Data
    {
        guard maxSize > 0 else
        {
            return Data()
        }

        if self.buffer.isEmpty
        {
            throw StrawError.bufferEmpty
        }

        var result = Data()
        while result.count < maxSize, !self.buffer.isEmpty
        {
            var chunk = self.buffer.removeFirst()
            let bytesNeeded = maxSize - result.count
            if chunk.count <= bytesNeeded
            {
                result.append(chunk)
            }
            else // chunk.count > bytesNeeded
            {
                let bytes = chunk[0..<bytesNeeded]
                result.append(bytes)
                chunk = chunk[bytesNeeded...]
                self.buffer.insert(chunk, at: 0)
            }
        }

        return result
    }

    public func peek(maxSize: Int) throws -> Data
    {
        guard maxSize > 0 else
        {
            return Data()
        }

        if self.buffer.isEmpty
        {
            throw StrawError.bufferEmpty
        }

        var result = Data()
        var index = 0
        while result.count < maxSize, index <= self.buffer.count
        {
            var chunk = self.buffer[index]
            let bytesNeeded = maxSize - result.count
            if chunk.count <= bytesNeeded
            {
                result.append(chunk)
            }
            else // chunk.count > bytesNeeded
            {
                let bytes = chunk[0..<bytesNeeded]
                result.append(bytes)
                chunk = chunk[bytesNeeded...]
            }

            index = index + 1
        }

        return result
    }

    public func clear(_ size: Int) throws
    {
        let _ = try self.read(size: size)
    }
}
