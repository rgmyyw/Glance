//
//  DefaultColltionCell.swift
//  Glance
//
//  Created by yanghai on 2020/9/11.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class DefaultColltionCell: CollectionViewCell {

    override func bind<T>(to viewModel: T) where T: DefaultColltionCellViewModel {
        super.bind(to: viewModel)
    }
}
