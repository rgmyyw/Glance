//
//  PermissionManager.swift
//  Glance
//
//  Created by yanghai on 2020/11/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import SPPermissions

class PermissionManager {
    
    static let shared = PermissionManager()
    
    private init() { }
    
    func requestPermissions(items : [SPPermission] = [.camera,.photoLibrary,.notification]) {
        let controller = SPPermissions.list(items)
        controller.dataSource = self
        controller.delegate = self
        guard let present = UIApplication.shared.keyWindow?.rootViewController?.topViewController() else { fatalError()}
        controller.present(on: present)
    }
}

extension PermissionManager : SPPermissionsDataSource, SPPermissionsDelegate {
    
    func configure(_ cell: SPPermissionTableViewCell, for permission: SPPermission) -> SPPermissionTableViewCell {
        return cell
    }
    
    func didHide(permissions ids: [Int]) {
        let permissions = ids.map { SPPermission(rawValue: $0)! }
        print("Did hide with permissions: ", permissions.map { $0.name })
    }
    
    func didAllow(permission: SPPermission) {
        print("Did allow: ", permission.name)
    }
    
    func didDenied(permission: SPPermission) {
        print("Did denied: ", permission.name)
    }
    
    func deniedData(for permission: SPPermission) -> SPPermissionDeniedAlertData? {
        return SPPermissionDeniedAlertData()
    }

}

