//
//  EmojiGroup.swift
//  promptchal
//
//  Created by German on 5/29/19.
//  Copyright © 2019 TopTier labs. All rights reserved.
//

import Foundation

public struct EmojiGroup {
    public var name: String
    public var subgroups: [EmojiGroup] = []
    public var emojis: [Emoji] = []

    init(name: String, subgroups: [EmojiGroup] = [], emojis: [Emoji] = []) {
        self.name = name
        self.subgroups = subgroups
        self.emojis = emojis
    }

    public var allEmojis: [Emoji] {
        return emojis + subgroups.flatMap { $0.allEmojis }
    }
}

//MARK: Codable protocol

extension EmojiGroup: Codable {
    private enum CodingKeys: String, CodingKey {
        case name, subgroups, emojis
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(subgroups, forKey: .subgroups)
        try container.encode(emojis, forKey: .emojis)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        subgroups = try container.decode([EmojiGroup].self, forKey: .subgroups)
        emojis = try container.decode([Emoji].self, forKey: .emojis)
    }
}
