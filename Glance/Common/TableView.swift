//
//  TableView.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

class TableView: UITableView {

    init () {
        super.init(frame: CGRect(), style: .grouped)
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {

        sectionHeaderHeight = 0
        sectionFooterHeight = 0
        backgroundColor = .clear
        cellLayoutMarginsFollowReadableWidth = false
        keyboardDismissMode = .onDrag
        separatorColor = .clear
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        tableHeaderView = UIView()
//        tableFooterView = UIView()
    }
}
