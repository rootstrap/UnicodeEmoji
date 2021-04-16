//
//  Emoji.swift
//  promptchal
//
//  Created by German on 5/29/19.
//  Copyright © 2019 TopTier labs. All rights reserved.
//

import Foundation

public enum UnicodeEmojiStatus: String {
    case component
    case unqualified
    case fullyQualified = "fully-qualified"
    case nonFullyQualified = "non-fully-qualified"
    case minimallyQualified = "minimally-qualified"
}

public struct Emoji {

    var unicode: String {
        didSet {
            setSequences()
        }
    }

    var unicodeSequences: [Substring]!
    var genderSequence: Substring?
    public var status: UnicodeEmojiStatus!
    public var variants: [Emoji] = []

    private static var genderIdentifiers = ["2642", "2640"]
    private static var skinToneIdentifiers = ["1F3FB", "1F3FC", "1F3FD", "1F3FE", "1F3FF"]
    private static var joinersAndSelectors = ["200D", "FE0F"]

    var prettyPrinted: String {
        description
    }

    var meaningfulSequences: [Substring] {
        let nonDeterminantSequences = Emoji.joinersAndSelectors + Emoji.skinToneIdentifiers
        return unicodeSequences.filter { !nonDeterminantSequences.contains(String($0)) }
    }

    init(unicode: String, status: UnicodeEmojiStatus = .fullyQualified, variants: [Emoji] = []) {
        self.unicode = unicode
        self.status = status
        self.variants = variants
        setSequences()
    }

    private mutating func setSequences() {
        unicodeSequences = unicode.split(separator: " ")
        genderSequence = unicodeSequences.first { Emoji.genderIdentifiers.contains(String($0)) }
    }
}

//MARK: Codable protocol

extension Emoji: Codable {

    private enum CodingKeys: String, CodingKey {
        case unicode, status, variants
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(unicode, forKey: .unicode)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(variants, forKey: .variants)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        unicode = try container.decode(String.self, forKey: .unicode)
        let statusValue = try container.decode(String.self, forKey: .status)
        status = UnicodeEmojiStatus(rawValue: statusValue) ?? .fullyQualified
        variants = try container.decode([Emoji].self, forKey: .variants)
        setSequences()
    }

    func isVariation(ofAnotherEmoji reference: Emoji) -> Bool {
        meaningfulSequences == reference.meaningfulSequences
            && (genderSequence == reference.genderSequence)
    }
}

extension Emoji: CustomStringConvertible {

    public var description: String {
        let unicodeSequences = unicode.split(separator: " ").map {
            "&#x\($0);".applyingTransform(.toXMLHex, reverse: true) ?? ""
        }
        return unicodeSequences.joined()
    }

}
