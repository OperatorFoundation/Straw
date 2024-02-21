//
//  SynchronizedStraw.swift
//
//
//  Created by Dr. Brandon Wiley on 9/4/23.
//

import Foundation
import Logging

// A variant of Straw for when you don't need thread safety
public class SynchronizedStraw
{
    let logger: Logger?

    var buffer: Data = Data()

    let lock = DispatchSemaphore(value: 1)

    public init(_ logger: Logger? = nil)
    {
        self.logger = logger
    }

    public func count() -> Int
    {
        defer
        {
            self.lock.signal()
        }
        self.lock.wait()

        return self.buffer.count
    }

    public func isEmpty() -> Bool
    {
        defer
        {
            self.lock.signal()
        }
        self.lock.wait()

        return self.count() == 0
    }

    public func write(_ chunk: Data)
    {
        defer
        {
            self.lock.signal()
        }
        self.lock.wait()

        self.buffer.append(chunk)
    }

    public func read() -> Data
    {
        defer
        {
            self.lock.signal()
        }
        self.lock.wait()

        let result = self.buffer
        self.buffer = Data()
        return result
    }

    public func read(size: Int) throws -> Data
    {
        defer
        {
            self.lock.signal()
        }
        self.lock.wait()

        self.logger?.trace("UnsafeStraw.read(size: \(size))")

        guard size > 0 else
        {
            return Data()
        }

        guard !self.buffer.isEmpty else
        {
            return Data()
        }

        guard self.count() >= size else
        {
            throw StrawError.notEnoughBytes(size, self.count())
        }

        let result = Data(self.buffer[..<size])
        self.buffer = Data(self.buffer[size...])

        return result
    }

    public func peek(size: Int) throws -> Data
    {
        defer
        {
            self.lock.signal()
        }
        self.lock.wait()

        guard size > 0 else
        {
            return Data()
        }

        guard !self.buffer.isEmpty else
        {
            return Data()
        }

        guard self.count() >= size else
        {
            throw StrawError.notEnoughBytes(size, self.count())
        }

        let result = Data(self.buffer[...size])

        return result
    }

    public func peek(offset: Int, size: Int) throws -> Data
    {
        defer
        {
            self.lock.signal()
        }
        self.lock.wait()

        guard size > 0 else
        {
            return Data()
        }

        guard !self.buffer.isEmpty else
        {
            return Data()
        }

        guard self.count() >= size else
        {
            throw StrawError.notEnoughBytes(size, self.count())
        }

        let result = Data(self.buffer[offset..<offset+size])

        return result
    }

    public func read(maxSize: Int) throws -> Data
    {
        defer
        {
            self.lock.signal()
        }
        self.lock.wait()

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
        defer
        {
            self.lock.signal()
        }
        self.lock.wait()

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
        defer
        {
            self.lock.signal()
        }
        self.lock.wait()

        let _ = try self.read(size: size)
    }
}
