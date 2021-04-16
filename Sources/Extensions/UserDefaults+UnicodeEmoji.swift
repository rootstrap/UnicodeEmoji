//
//  UserDefaults+UnicodeEmoji.swift
//  UnicodeEmoji
//
//  Created by German on 16/4/21.
//  Copyright © 2021 Rootstrap. All rights reserved.
//

import Foundation

internal extension UserDefaults {

    enum Key {
        static let storedEmojiVersions = "UnicodeEmoji.emoji-versions"
    }

    var emojiList: VersionedUnicodeEmojis {
        get {
            if
                let storedData = value(forKey: Key.storedEmojiVersions) as? Data,
                let value = try? PropertyListDecoder().decode(
                    VersionedUnicodeEmojis.self, from: storedData
                )
            {
                return value
            }
            return [:]
        }

        set {
            let enconded = try? PropertyListEncoder().encode(newValue)
            set(enconded, forKey: Key.storedEmojiVersions)
        }
    }
}
