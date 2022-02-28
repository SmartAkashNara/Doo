//
//  LinkLabelHelper.swift
//  LinkLabelDemo
//
//  Created by Krunal's Macbook Pro on 27/11/19.
//  Copyright © 2019 Krunal's Macbook Pro. All rights reserved.
//

import UIKit
import TTTAttributedLabel

struct LinkLabelHelper {

    //MARK:- Variables
    var labelTTTAttributedLabel: TTTAttributedLabel!
    
    struct RangesWithDataArray {
        var ranges = [NSRange]()
        var dataArray = [[AnyHashable: Any]]()
    }
    
    static var tagDataKeyName = "tagName"
    static var keybordDataKeyName = "keywordName"

    init(label: TTTAttributedLabel) {
        self.labelTTTAttributedLabel = label
    }
    
    struct FormatedStringWithLinksRange {
        var fullAttributedText: NSMutableAttributedString
        var linksRangeArray: [NSRange]
    }
    
    //MARK:- Tag link methods
    func formatTagAndKeywordAsLinkAndMakeItClickable(fullText: String, fullTextAttributes: [NSAttributedString.Key: Any], tagSignArray: [String], tagSignAttributesArray: [[NSAttributedString.Key: Any]], keywordArray: [String], keywordAttributesArray: [[NSAttributedString.Key: Any]], isUnderlineActive: Bool) {

        //SUGGESION: REMOVE ALL EMPTY STUFF HERE
        guard tagSignArray.count == tagSignAttributesArray.count else { return }
        guard keywordArray.count == keywordAttributesArray.count else { return }

        // Color
        formattingTagsAndKeywordAsLinksWithWholeText(fullText: fullText, fullTextAttributes: fullTextAttributes, tagSignArray: tagSignArray, tagSignAttributesArray: tagSignAttributesArray, keywordArray: keywordArray, keywordAttributesArray: keywordAttributesArray) { (allAttributedText, objRangesWithDataArray) in

            bindLinksWith(allAttributedText: allAttributedText,
                                isUnderlineActive: isUnderlineActive,
                                linkRanges: objRangesWithDataArray.ranges,
                                linkedDataArray: objRangesWithDataArray.dataArray)

        }
    }

    private func formattingTagsAndKeywordAsLinksWithWholeText(
        fullText: String,
        fullTextAttributes: [NSAttributedString.Key: Any],
        tagSignArray: [String],
        tagSignAttributesArray: [[NSAttributedString.Key: Any]],
        keywordArray: [String],
        keywordAttributesArray: [[NSAttributedString.Key: Any]],
        callback: (_ fullAttributedText: NSMutableAttributedString, _ rangesAndFilteredTags: RangesWithDataArray) -> ()) {
        
        var rangesAndFilteredTagsOfAllSign = RangesWithDataArray()
        var fullAttributedText = NSMutableAttributedString(string: fullText)
        fullAttributedText.setAttributes(fullTextAttributes, range: NSMakeRange(0, fullAttributedText.string.count))

        func formattingAsLinkAndAddDataInAllSignOrKeyword(rangesAndFilteredTagsIndividualSign: RangesWithDataArray, targetTextAttributes: [NSAttributedString.Key: Any]) {
            fullAttributedText = formattingAsLink(fullAttributedText: fullAttributedText, targetRanges: rangesAndFilteredTagsIndividualSign.ranges, targetTextAttributes: targetTextAttributes)

            rangesAndFilteredTagsOfAllSign.ranges += rangesAndFilteredTagsIndividualSign.ranges
            rangesAndFilteredTagsOfAllSign.dataArray += rangesAndFilteredTagsIndividualSign.dataArray
        }
        for i in 0..<tagSignArray.count {
            let rangesAndFilteredTagsIndividualSign = fullAttributedText.string.rangesAndFilteredDataConnectedWith(tagSign: tagSignArray[i])
            formattingAsLinkAndAddDataInAllSignOrKeyword(rangesAndFilteredTagsIndividualSign: rangesAndFilteredTagsIndividualSign, targetTextAttributes: tagSignAttributesArray[i])
        }
        for i in 0..<keywordArray.count {
            let rangesAndFilteredTagsIndividualSign = fullAttributedText.string.rangesAndDataOf(keyword: keywordArray[i])
            formattingAsLinkAndAddDataInAllSignOrKeyword(rangesAndFilteredTagsIndividualSign: rangesAndFilteredTagsIndividualSign, targetTextAttributes: keywordAttributesArray[i])
        }
        callback(fullAttributedText, rangesAndFilteredTagsOfAllSign)
    }
    
    private func formattingAsLink(
        fullAttributedText: NSMutableAttributedString,
        targetRanges: [NSRange],
        targetTextAttributes: [NSAttributedString.Key: Any]
    ) -> NSMutableAttributedString {

        targetRanges.forEach { (targetRange) in
//            fullAttributedText.setAttributes(targetTextAttributes, range: targetRange)
            fullAttributedText.addAttributes(targetTextAttributes, range: targetRange)
}
        return fullAttributedText
    }

    private func bindLinksWith(
        allAttributedText: NSAttributedString,
        isUnderlineActive: Bool,
        linkRanges: [NSRange],
        linkedDataArray: [[AnyHashable : Any]]) {
        
        guard linkRanges.count == linkedDataArray.count else { return }
        labelTTTAttributedLabel.numberOfLines = 0
        labelTTTAttributedLabel.attributedText = allAttributedText
        let dismissUnderlinedAttribute = [NSAttributedString.Key.underlineStyle: isUnderlineActive]
        // Default is 'Underlined'
        labelTTTAttributedLabel.activeLinkAttributes = dismissUnderlinedAttribute
        labelTTTAttributedLabel.linkAttributes = dismissUnderlinedAttribute
        labelTTTAttributedLabel.addCustomLinkToTransitInformation(linkRanges: linkRanges, linkedDataArray: linkedDataArray)
    }
    
}

//MARK:- public extentions
extension TTTAttributedLabel {
    // add multiple links with same name to TTTAttributedLabel
    func addCustomLinkToTransitInformation(linkText: String, linkedData: [AnyHashable : Any]) {
        let text = attributedText.string
        let linkTextRanges = text.nsRanges(of: linkText)
        linkTextRanges.forEach { (linkTextRange) in
            addLink(toTransitInformation: linkedData, with: linkTextRange)
        }
    }
    
    func addCustomLinkToTransitInformation(linkRanges: [NSRange], linkedDataArray: [[AnyHashable: Any]]) {
        guard linkRanges.count == linkedDataArray.count else { return }
        //linkRanges[i].location+1 -> this is temparory code right now.
        for i in 0..<linkRanges.count{
            var updatedRange = NSRange()
            let lastKeywordCount = linkRanges[i].location + linkRanges[i].length
            if lastKeywordCount < attributedText.string.count {
                updatedRange = NSRange(location: linkRanges[i].location+1, length: linkRanges[i].length)
            } else {
                updatedRange = linkRanges[i]
            }
            addLink(toTransitInformation: linkedDataArray[i], with: updatedRange)
        }
    }

//    func addCustomLinkToTransitInformation(linkRanges: [NSRange], linkedDataArray: [[AnyHashable: Any]]) {
//        guard linkRanges.count == linkedDataArray.count else { return }
//        for i in 0..<linkRanges.count{
//            addLink(toTransitInformation: linkedDataArray[i], with: updatedRange)
//        }
//    }
}

extension String {
    func ranges(of searchString: String) -> [Range<String.Index>] {
        let _indices = indices(of: searchString)
        let count = searchString.count
        return _indices.map({ index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0+count) })
    }
    
    func nsRanges(of searchString: String) -> [NSRange] {
        let _indices = indices(of: searchString)
        let count = searchString.count
        return _indices.map({ NSRange(location: $0, length: count) })
    }
    
    func nsRange(of: String) -> NSRange {
        return self.toNSString.range(of: of)
    }
}


extension String {
    func indices(of occurrence: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, range: position..<endIndex) {
            let i = distance(from: startIndex,
                             to: range.lowerBound)
            indices.append(i)
            let offset = occurrence.distance(from: occurrence.startIndex,
                                             to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                                        break
            }
            position = index(after: after)
        }
        return indices
    }
    
    func rangesAndFilteredDataConnectedWith(tagSign: String) -> (LinkLabelHelper.RangesWithDataArray) {
        //tags will give removed by sign
        var tagDictionaryArray = [[AnyHashable: Any]]()
        var matchedRanges = [NSRange]()
        var position = startIndex
        while let range = range(of: tagSign, range: position..<endIndex) {
            let i = distance(from: startIndex,
                             to: range.lowerBound)
            if var firstMatchedTag = self.getFirstTagPrefixWith(tagSign: tagSign, startFrom: i) {
                matchedRanges.append(NSRange(location: i, length: firstMatchedTag.count))
                firstMatchedTag.removeFirst()
                let tagDictionary = [LinkLabelHelper.tagDataKeyName: firstMatchedTag]
                tagDictionaryArray.append(tagDictionary)
            }
            
            let offset = tagSign.distance(from: tagSign.startIndex,
                                             to: tagSign.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                                        break
            }
            position = index(after: after)
        }
        return LinkLabelHelper.RangesWithDataArray(ranges: matchedRanges, dataArray: tagDictionaryArray)
    }

    func rangesAndDataOf(keyword: String) -> (LinkLabelHelper.RangesWithDataArray) {
        //keywords will give removed by sign
        var keywordDictionaryArray = [[AnyHashable: Any]]()
        var matchedRanges = [NSRange]()
        matchedRanges = self.nsRanges(of: keyword)
        let keywordDictionary = [LinkLabelHelper.keybordDataKeyName: keyword]
        keywordDictionaryArray = [[AnyHashable: Any]](repeating: keywordDictionary, count: matchedRanges.count)
        return LinkLabelHelper.RangesWithDataArray(ranges: matchedRanges, dataArray: keywordDictionaryArray)
    }

}

extension Range where Bound == String.Index {
    func toNSRange(labelText: String) -> NSRange {
        let matchRangeStart: Int = labelText.distance(from: labelText.startIndex, to: lowerBound)
        let matchRangeEnd: Int = labelText.distance(from: labelText.startIndex, to: upperBound)
        let matchRangeLength: Int = matchRangeEnd - matchRangeStart
        return NSMakeRange(matchRangeStart, matchRangeLength)
    }
}


extension String {
    func hashtags() -> [String] {
        if let regex = try? NSRegularExpression(pattern: "#[a-z0-9]+", options: .caseInsensitive) {
            let string = self as NSString
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "#", with: "").lowercased()
            }
        }
        return []
    }

    func getTagsPrefixWith(tagSign: String) -> [String] {
        if let regex = try? NSRegularExpression(pattern: "\(tagSign)[a-z0-9]+", options: .caseInsensitive) {
            let string = self as NSString
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range)//.replacingOccurrences(of: tagSign, with: "").lowercased()
            }
        }
        return []
    }
    
    func getFirstTagPrefixWith(tagSign: String, startFrom: Int) -> String? {
        if let regex = try? NSRegularExpression(pattern: "\(tagSign)[a-z0-9._-]+", options: .caseInsensitive) {
            let string = self as NSString
            let length = string.length - startFrom
            let matchedNSTextCheckingResults = regex.matches(in: self, options: [], range: NSRange(location: startFrom, length: length))
            if let matchedFirstNSTextCheckingResult = matchedNSTextCheckingResults.first {
                return string.substring(with: matchedFirstNSTextCheckingResult.range)
            }
        }
        return nil
    }
}
