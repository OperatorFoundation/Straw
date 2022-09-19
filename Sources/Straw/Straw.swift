//
//  Straw.swift
//  
//
//  Created by Joshua Clark on 9/19/22.
//

import Foundation

import Chord

public class Straw
{
    public var count: Int
    {
        let result: Int = AsyncAwaitSynchronizer<Int>.sync
        {
            return await self.actor.count
        }
        
        return result
    }
    
    public var isEmpty: Bool
    {
        return self.count == 0
    }
    
    let actor: StrawActor
    
    public convenience init()
    {
        let strawActor = StrawActor()
        self.init(actor: strawActor)
    }
    
    public init(actor: StrawActor)
    {
        self.actor = actor
    }
    
    public func write(_ chunk: Data)
    {
        AsyncAwaitEffectSynchronizer.sync
        {
            await self.actor.write(chunk)
        }
    }

    public func write(_ chunks: [Data])
    {
        AsyncAwaitEffectSynchronizer.sync
        {
            await self.actor.write(chunks)
        }
    }

    public func read() throws -> Data
    {
        let result: Data = try AsyncAwaitThrowingSynchronizer<Data>.sync
        {
            return try await self.actor.read()
        }
        
        return result
    }

    public func readAllChunks() throws -> [Data]
    {
        let result: [Data] = try AsyncAwaitThrowingSynchronizer<[Data]>.sync
        {
            return try await self.actor.readAllChunks()
        }
        
        return result
    }

    public func readAllData() throws -> Data
    {
        let result: Data = try AsyncAwaitThrowingSynchronizer<Data>.sync
        {
            return try await self.actor.readAllData()
        }
        
        return result
    }

    public func read(size: Int) throws -> Data
    {
        let result: Data = try AsyncAwaitThrowingSynchronizer<Data>.sync
        {
            return try await self.actor.read(size: size)
        }
        
        return result
    }

    public func read(maxSize: Int) throws -> Data
    {
        let result: Data = try AsyncAwaitThrowingSynchronizer<Data>.sync
        {
            return try await self.actor.read(maxSize: maxSize)
        }
        
        return result
    }
}
