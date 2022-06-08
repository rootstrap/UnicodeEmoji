//
//  EmojiLoader.swift
//  promptchal
//
//  Created by German on 5/28/19.
//  Copyright © 2019 TopTier labs. All rights reserved.
//

import Foundation

public typealias VersionedUnicodeEmojis = [String: EmojiCollection]
public typealias EmojiListCompletion = (
    _ emojis: EmojiCollection?,
    _ error: Error?
) -> Void

public enum UnicodeEmojiVersion {

    public static var current: String {
        if #available(iOS 15.4, *) {
            return "14.0"
        }

        if #available(iOS 14.5, *) {
            return "13.1"
        }

        if #available(iOS 14.2, *) {
            return "13.0"
        }

        if #available(iOS 13, *) {
            return "12.1"
        }

        if #available(iOS 12.1, *) {
            return "11.0"
        }

        if #available(iOS 11.1, *) {
            return "5.0"
        }

        return "4.0"
    }

}

public class EmojiLoader {

    public static let shared = EmojiLoader()

    private let unicodePublicFolder = "https://unicode.org/Public/emoji/"
    private let testFileName = "/emoji-test.txt"

    private(set) var emojiList: VersionedUnicodeEmojis {
        get {
            UserDefaults.standard.emojiList
        }
        set {
            UserDefaults.standard.emojiList = newValue
        }
    }

    public var emojiCollection: EmojiCollection? {
        emojiList[UnicodeEmojiVersion.current]
    }

    public var needsReload: Bool {
        guard
            let loadedEmojis = emojiList[UnicodeEmojiVersion.current],
            !loadedEmojis.groups.isEmpty
        else {  return true }

        return false
    }

    public func preload() {
        if needsReload { recommendedEmojis(forceReload: true) }
    }

    func recommendedEmojis(
        forceReload: Bool = false,
        completion: EmojiListCompletion? = nil
    ) {
        load(unicodeVersion: UnicodeEmojiVersion.current, reload: forceReload) { (emojis, error) in
            DispatchQueue.main.async {
                completion?(emojis, error)
            }
        }
    }

    // Get Unicode emoji versions here: https://unicode.org/Public/emoji/
    private func load(
        unicodeVersion version: String, reload: Bool,
        completion: @escaping EmojiListCompletion
    ) {
        if let loadedEmojis = emojiList[version], !reload {
            completion(loadedEmojis, nil)
            return
        }

        guard let url = URL(string: unicodePublicFolder + version + testFileName) else {
            completion(
                nil,
                error(withDescription: "The provided version doesn't appear to be valid in Unicode.")
            )
            return
        }

        loadTestFile(url: url) { (response, error) in
            guard let testData = response, error == nil else {
                completion(nil, error!)
                return
            }

            let parsedEmojis = EmojiCollection(unicodeTestData: testData)
            self.emojiList[version] = parsedEmojis

            completion(parsedEmojis, nil)
        }
    }

    private func loadTestFile(
        url: URL,
        completion: @escaping (_ testResponse: String?, _ error: Error?) -> Void
    ) {
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard
                let data = data,
                let readString = String(data: data, encoding: .utf8),
                error == nil
            else {
                completion(nil, error!)
                return
            }

            completion(readString, nil)
        }

        task.resume()
    }

    private func error(withDescription desc: String) -> Error {
        return NSError(
            domain: "UnicodeEmoji.EmojiLoader", code: 0,
            userInfo: [NSLocalizedDescriptionKey: desc]
        )
    }
}
