//
//  MenuViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

// why indirect: https://medium.com/@leandromperez/bidirectional-associations-using-value-types-in-swift-548840734047
indirect enum MenuLayoutEnum {
    case box
    case flat
    case combined(MenuDataModel)
    case combinedFlat(MenuDataModel)
}

struct MenuDataModel {
    var id: Int = 0
    var title: String = ""
    var image = ""
    var enable = false
    var layout: MenuLayoutEnum = .box
}

class MenuViewModel {
    var arrayMenuList = [MenuDataModel]()
    var isMenuListUpdatedBasedOnEnterprise: Bool = false
    var selectedPosition: Int = 0

    // Only for local testing.
    func testingMenuList(){
        ENTERPRISE_LIST.append(EnterpriseModel.init(id: 0, name: "Rody's Home"))
        ENTERPRISE_LIST.append(EnterpriseModel.init(id: 1, name: "City Office"))
        ENTERPRISE_LIST.append(EnterpriseModel.init(id: 2, name: "Classic Cafe"))
    }
    
    func prepareMenuLayout(){
        arrayMenuList.removeAll()
        
        
        // Menu removed for sept launch
        /*
        arrayMenuList.append(MenuDataModel.init(id: 0, title: "Streaming", image: "streamingMenuIcon"))
         */
        
        let alexaLayoutModel = MenuDataModel.init(id: 1, title: "Siri", image: "siri_menu")
        arrayMenuList.append(MenuDataModel.init(id: 0, title: "Alexa", image: "amazon-alexa", layout: .combinedFlat(alexaLayoutModel)))
        arrayMenuList.append(MenuDataModel.init(id: 2, title: localizeFor("home_tab"), image: "homeMenuIcon", layout: .box))
        arrayMenuList.append(MenuDataModel.init(id: 3, title: localizeFor("groups_menu"), image: "groupsMenuIcon", layout: .box))
        
        let scenesLayoutModel = MenuDataModel.init(id: 5, title: localizeFor("scenes"), image: "scenesMenuIcon")
        arrayMenuList.append(MenuDataModel.init(id: 4, title: localizeFor("devices_menu"), image: "devicesMenuIcon", layout: .combined(scenesLayoutModel)))
        
        arrayMenuList.append(MenuDataModel.init(id: 6, title: localizeFor("schedules_menu"), image: "schedulesMenuIcon", layout: .box))
        
        // Invite User and User & Privileges menu will be seen only For Admin user type. Keep it hidden for Normal users
        arrayMenuList.append(getInviteUsersMenuModel)
        arrayMenuList.append(getUserAndPrivilegesMenuModel)
        
        arrayMenuList.append(MenuDataModel.init(id: 9, title: localizeFor("received_invitations_menu"), image: "received_invitation_icon", layout: .flat))
        arrayMenuList.append(MenuDataModel.init(id: 10, title: localizeFor("settings_button"), image: "settingsMenuIcon", layout: .flat))
        arrayMenuList.append(MenuDataModel.init(id: 10, title: localizeFor("firmware_upgrade_menu"), image: "firmware_update_menu", layout: .flat))
    }
    lazy var getInviteUsersMenuModel: MenuDataModel = {
        return MenuDataModel.init(id: 7, title: localizeFor("invite_users_menu"), image: "inviteUserMenuIcon", layout: .box)
    }()
    lazy var getUserAndPrivilegesMenuModel: MenuDataModel = {
        return MenuDataModel.init(id: 8, title: localizeFor("user_and_privileges_menu"), image: "userAndPrivilegesMenuIcon", layout: .box)
    }()
    
    func removeInviteUsersAndUserAndPrivilegesOptionsIfAvailable() {
        arrayMenuList = arrayMenuList.filter({ menuModel in
            if menuModel.title == localizeFor("invite_users_menu") {
                return false
            }else if menuModel.title == localizeFor("user_and_privileges_menu") {
                return false
            }else{
                return true
            }
        })
        // Menu updated based on enterprise.
        self.isMenuListUpdatedBasedOnEnterprise = true
    }
    func addInviteUsersAndUserAndPrivilegesOptionsIfNotAvailable() {
        if let indexOfReceivedInvitations = self.arrayMenuList.firstIndex(where: {$0.title == localizeFor("received_invitations_menu")}) {
            if !self.arrayMenuList.contains(where: {$0.title == localizeFor("invite_users_menu")}) {
                self.arrayMenuList.insert(getInviteUsersMenuModel,
                                          at: indexOfReceivedInvitations)
                
                if !self.arrayMenuList.contains(where: {$0.title == localizeFor("user_and_privileges_menu")}) {
                    self.arrayMenuList.insert(getUserAndPrivilegesMenuModel,
                                          at: indexOfReceivedInvitations+1)
                }
            }
        }
        // Menu updated based on enterprise.
        self.isMenuListUpdatedBasedOnEnterprise = true
    }
}

// MARK: Enterprises List.
extension MenuViewModel {
    
    func callGetEnterprises(success: (()->())? = nil,
                            failure: (()->())? = nil,
                            internetFailure: (()->())? = nil,
                            failureInform: (()->())? = nil,
                            switchToAddEnteprise: (()->())? = nil) {

        /*
        let params = ["page": 0,
                      "size": 0,
                      "sort": ["column": "createdAt",
                               "sortType": "asc"
            ],
                      "criteria": [
                        ["column": "name",
                         "operator": "like",
                         "values": [""]
                        ]
            ]
            ] as [String: Any]
 */
        
        let params = ["page": 0,
                      "size": 1000] as [String: Any]
        
        // Skeleton work
        API_SERVICES.callAPI(params, path: .getEnterprises) { parsingResponse in
            print("Parsing response of enterprises list: \(String(describing: parsingResponse))")
            if let strongParsingResponse = parsingResponse,
                self.parseEnterprises(JSON.init(strongParsingResponse)) {
                success?()
            }else{
                switchToAddEnteprise?()
            }
        } failure: { failureMessage in
            failure?()
        } internetFailure: {
            internetFailure?()
        } failureInform: {
            failureInform?()
        }
    }
    
    func parseEnterprises(_ response: JSON) -> Bool {
        guard let user = APP_USER else {return false}
        if let enterprises = response.dictionary?["payload"]?.dictionary?["content"]?.arrayValue{
            ENTERPRISE_LIST.removeAll()
            for index in 0..<enterprises.count {
                let enterpriseJson = enterprises[index]
                let enterprise = EnterpriseModel.init(dict: enterpriseJson)
                // Suppose you have enterprise Id and don't have enterprise till now. while parsing all enterprises, will add selected enterprise model by checking selected enterprise id.
                if user.userSelectedEnterpriseID == enterprise.id {
                    user.selectedEnterprise = enterprise
                    self.selectedPosition = index
                }
                ENTERPRISE_LIST.append(enterprise)
            }
            
            // Temporary --------- (Setting first enterprise as default)
            /*
            if ENTERPRISE_LIST.count != 0 {
                if let user = APP_USER {
                    user.selectedEnterprise = ENTERPRISE_LIST[0]
                }
            }
 */
            // -------------------
            
            if ENTERPRISE_LIST.count != 0 {
                return true
            }else{
                return false
            }
        }
        return false
    }
}
