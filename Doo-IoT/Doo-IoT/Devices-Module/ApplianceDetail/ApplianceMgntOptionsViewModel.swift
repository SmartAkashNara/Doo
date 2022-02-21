//
//  ApplianceMgntOptionsViewModel.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 09/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class ApplianceMgntOptionsViewModel {
    enum EnumMenu: Int { case schedulers = 0, accessHistory, bindingList, groups }
    
    struct Menu{
        var image = ""
        var name = ""
    }
    
    var arrayMenu = [Menu]()
    func loadMenu() {
        arrayMenu = [
            Menu(image: "schedulesMenuIcon", name: localizeFor("schedulers")),
            Menu(image: "settingsMenuIcon", name: localizeFor("access_history")),
            Menu(image: "settingsMenuIcon", name: localizeFor("binding_list")),
            Menu(image: "groupsMenuIcon", name: localizeFor("groups"))
        ]
    }
}
