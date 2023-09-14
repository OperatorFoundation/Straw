//
//  Straw.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/11/22.
//

import Foundation

public actor StrawActor
{
    public var count: Int
    {
        return self.buffer.reduce(0) { $0 + $1.count }
    }
    
    public var isEmpty: Bool
    {
        return self.count == 0
    }
    
    var buffer: [Data] = []

    public init()
    {
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
            return Data()
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
            return Data()
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
        while result.count < size
        {
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
        }

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
            return Data()
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
}

public enum StrawError: Error
{
    case bufferEmpty
    case badReadSize(Int)
    case notEnoughBytes(Int, Int) // requested, actual
}
