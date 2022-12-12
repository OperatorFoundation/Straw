//
//  SynchronizedStrawActor.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/12/22.
//

import Foundation

public actor SynchronizedStrawActor
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
    let lock: DispatchSemaphore = DispatchSemaphore(value: 0)

    public init()
    {
    }

    public func write(_ chunk: Data)
    {
        self.buffer.append(chunk)
        self.lock.signal()
    }

    public func write(_ chunks: [Data])
    {
        self.buffer.append(contentsOf: chunks)

        for _ in chunks
        {
            self.lock.signal()
        }
    }

    public func read() throws -> Data
    {
        self.lock.wait()

        return self.buffer.removeFirst()
    }

    public func readAllChunks() throws -> [Data]
    {
        for _ in self.buffer
        {
            self.lock.wait()
        }

        let result = self.buffer
        self.buffer = []
        return result
    }

    public func readAllData() throws -> Data
    {
        var result = Data()
        for chunk in self.buffer
        {
            self.lock.wait()

            result.append(chunk)
        }

        self.buffer = []

        return result
    }

    public func read(size: Int) throws -> Data
    {
        guard size > 0 else
        {
            throw StrawError.badReadSize(size)
        }

        let count = self.buffer.reduce(0) { $0 + $1.count }
        guard count >= size else
        {
            throw StrawError.notEnoughBytes(size, count)
        }

        var result = Data()
        while result.count < size
        {
            self.lock.wait()

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
                self.lock.signal()
            }
        }

        return result
    }

    public func read(maxSize: Int) throws -> Data
    {
        guard maxSize > 0 else
        {
            throw StrawError.badReadSize(maxSize)
        }

        var result = Data()
        while result.count < maxSize, !self.buffer.isEmpty
        {
            self.lock.wait()

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

                self.lock.signal()
            }
        }

        return result
    }
}
