//
//  EmojiCollection.swift
//  promptchal
//
//  Created by German on 5/28/19.
//  Copyright © 2019 TopTier labs. All rights reserved.
//

import Foundation

public class EmojiCollection: Codable {

    private static let fileEndPattern = "#EOF"
    private static let emojiLinePattern = "^(\\w{4,}(?:(?: \\w{4,})+)?)\\s*;\\s*(fully-qualified|non-fully-qualified|minimally-qualified|unqualified)\\s*#"

    private static let separatorFormat = "#\\s+%@:\\s+(.*)"

    private static let groupRegex = try? NSRegularExpression(pattern: String(format: separatorFormat, "group"), options: [])
    private static let subgroupRegex = try? NSRegularExpression(pattern: String(format: separatorFormat, "subgroup"), options: [])
    private static let emojiRegex = try? NSRegularExpression(pattern: EmojiCollection.emojiLinePattern, options: [])

    public var groups: [EmojiGroup] = []

    init(unicodeTestData data: String) {
        let lines = data.components(separatedBy: .newlines)
        build(fromLines: lines)
        filterBadGroups()
    }

    private func build(fromLines lines: [String]) {
        var index = 0
        while index < lines.count {
            let line = lines[index]
            index += 1
            if let groupName = regex(EmojiCollection.groupRegex, matchIn: line) {
                let subgroups = parseSubgroups(index: &index, lines: lines)
                let newGroup = EmojiGroup(name: groupName, subgroups: subgroups)
                groups.append(newGroup)
            }
        }
    }

    private func parseSubgroups(index: inout Int, lines: [String]) -> [EmojiGroup] {
        var subgroups: [EmojiGroup] = []
        while index < lines.count {
            let line = lines[index]
            if regex(EmojiCollection.groupRegex, matchIn: line) != nil || line.contains(EmojiCollection.fileEndPattern) {
                return subgroups
            }
            index += 1
            if let subgroupName = regex(EmojiCollection.subgroupRegex, matchIn: line) {
                let emojis = parseEmojis(index: &index, lines: lines)
                let newGroup = EmojiGroup(name: subgroupName, emojis: emojis)
                subgroups.append(newGroup)
            }
        }
        return subgroups
    }

    private func parseEmojis(index: inout Int, lines: [String]) -> [Emoji] {
        var emojis: [Emoji] = []
        while index < lines.count {
            let line = lines[index]
            if regex(EmojiCollection.groupRegex, matchIn: line) != nil ||
                regex(EmojiCollection.subgroupRegex, matchIn: line) != nil || line.contains(EmojiCollection.fileEndPattern) {
                return emojis
            }
            if let unicodeMatch = regex(EmojiCollection.emojiRegex, matchIn: line),
               let statusMatch = regex(EmojiCollection.emojiRegex, matchIn: line, capturedGroup: 2),
               let status = UnicodeEmojiStatus(rawValue: statusMatch), status == .fullyQualified {

                let newEmoji = Emoji(unicode: unicodeMatch, status: status)
                if let originalEmoji = emojis.firstIndex(where: { newEmoji.isVariation(ofAnotherEmoji: $0) }) {
                    emojis[originalEmoji].variants.append(newEmoji)
                } else {
                    emojis.append(newEmoji)
                }
            }
            index += 1
        }
        return emojis
    }

    private func regex(_ regex: NSRegularExpression?,
                       matchIn target: String,
                       capturedGroup: Int = 1) -> String? {
        guard let regex = regex else { return nil }
        // First range of match is the full match, the second one is the group/subgroup name
        if let match = regex.firstMatch(in: target, options: [],
                                        range: NSRange(location: 0, length: target.utf16.count)),
           match.numberOfRanges > capturedGroup, let titleRange = Range(match.range(at: capturedGroup), in: target) {
            return String(target[titleRange])
        }
        return nil
    }

    private func filterBadGroups() {
        var filteredGroups = groups.filter { $0.name.lowercased() != "component" }
        for i in 0..<filteredGroups.count {
            var group = filteredGroups[i]
            if let badSubgroup = group.subgroups.firstIndex(where: { $0.name.lowercased() == "skin-tone" }) {
                group.subgroups.remove(at: badSubgroup)
                filteredGroups.remove(at: i)
                filteredGroups.insert(group, at: i)
                break
            }
        }
        groups = filteredGroups
    }

    //MARK: Codable protocol

    private enum CodingKeys: String, CodingKey {
        case groups
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(groups, forKey: .groups)
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        groups = try container.decode([EmojiGroup].self, forKey: .groups)
    }
}
