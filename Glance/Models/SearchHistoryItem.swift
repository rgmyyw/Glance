//
//  SearchHistoryItem.swift
//  Glance
//
//  Created by yanghai on 2020/9/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper
import KeychainAccess
import RxSwift
import RxCocoa


private let searchHistoryKey = "AllSearchHistory"
private let keychain = Keychain(service: Configs.App.bundleIdentifier)
let searchHistory = BehaviorRelay<[SearchHistoryItem]>(value: [])

struct SearchHistoryItem : Mappable {
    var text : String
    init?(map: Map) {
        text = ""
    }
    
    mutating func mapping(map: Map) {
        text <- map["text"]
    }
    
    init(text : String) {
        self.text = text
    }
}

extension SearchHistoryItem {

    func save() {
        var items = searchHistory.value
        items.insert(self, at: 0)
        items.removeDuplicates()
        searchHistory.accept(items)
        if let json = items.toJSONString() {
            keychain[searchHistoryKey] = json
        } else {
            logError("History can't be saved")
        }
    }
    
    static func remove(item : SearchHistoryItem) {
        SearchHistoryItem.remove(items: [item])
    }

    
    static func remove(items : [SearchHistoryItem]) {
        var all = searchHistory.value
        items.forEach { (item) in
            if let index = all.firstIndex(of: item) {
                all.remove(at: index)
            }
        }
        searchHistory.accept(all)
        if let json = items.toJSONString() {
            keychain[searchHistoryKey] = json
        } else {
            logError("History can't be saved")
        }

    }
    static func removeAll() {
        keychain[searchHistoryKey] = nil
        searchHistory.accept([])
    }


    static func currentAllHistory() -> [SearchHistoryItem] {
        if let json = keychain[searchHistoryKey], let items = [SearchHistoryItem](JSONString: json) {
            return items
        }
        return []
    }

}




extension SearchHistoryItem : Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.text == rhs.text
    }
}

