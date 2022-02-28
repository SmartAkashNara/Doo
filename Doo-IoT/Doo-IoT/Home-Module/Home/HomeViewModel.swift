//
//  HomeViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class HomeViewModel {
    
    enum LayoutFor {
        case favAppliances, scenes
    }
    struct HomeLayouts {
        var layoutID = UUID().uuidString
        var layoutTitle = ""
        var layoutData: [Any] = []
        var showAllData: Bool = true
        var isDataFetched: Bool = false
        var layoutFor: LayoutFor
    }
    
    var homeLayouts: [HomeLayouts] = []
    
    func loadAppliancesAndScenesLayouts() {
        homeLayouts.removeAll() // fresh startup
        let applianceLayout = HomeViewModel.HomeLayouts.init(layoutTitle: localizeFor("favourite_devices"), showAllData: false, layoutFor: .favAppliances)
        let scenesLayout = HomeViewModel.HomeLayouts.init(layoutTitle: localizeFor("scenes"), showAllData: false, layoutFor: .scenes)
        self.homeLayouts.append(applianceLayout)
        self.homeLayouts.append(scenesLayout)
    }

    //======================== Favourite List ======================
    func callGetAllFavouriteAPI(success: (()->())? = nil,
                             failure: (()->())? = nil,
                             internetFailure: (()->())? = nil,
                             failureInform: (()->())? = nil) {
        
        API_SERVICES.callAPI(path: .getFavourites, method: .post) { [weak self] parsingResponse in
            if let strongParsingResponse = parsingResponse {
                print("Favourite devices: \(strongParsingResponse)")
                self?.parseAllFavouriteList(JSON.init(strongParsingResponse))
                // self?.preparedFavouriteStaticData()
                // debugPrint(strongParsingResponse)
            }
            success?()
        } failure: { failureMessage in
            failure?()
        } internetFailure: {
            internetFailure?()
        } failureInform: {
            failureInform?()
        }
    }
    
    func parseAllFavouriteList(_ response: JSON)  {        
        var favouriteDevicesFinalized: [ApplianceDataModel] = []
        guard let arrayApplience = response["payload"].dictionary?["content"]?.array else { return  }
        
        if arrayApplience.count != 0 {
            for applienceObj in arrayApplience {
                favouriteDevicesFinalized.append(ApplianceDataModel.init(fromFavourite: applienceObj))
            }
            
            if let indexOfFavAppliance = self.homeLayouts.firstIndex(where: {$0.layoutFor == .favAppliances}) {
                // Already available
                self.homeLayouts[indexOfFavAppliance].layoutData = favouriteDevicesFinalized
                self.homeLayouts[indexOfFavAppliance].isDataFetched = true
                
            } else {
                // add
                var applianceLayout = HomeViewModel.HomeLayouts.init(layoutTitle: localizeFor("favourite_devices"), showAllData: false, layoutFor: .favAppliances)
                applianceLayout.layoutData = favouriteDevicesFinalized
                if self.homeLayouts.count != 0 {
                    self.homeLayouts.insert(applianceLayout, at: 0)
                }else{
                    self.homeLayouts.append(applianceLayout)
                }
            }
        }else{
            // Clear layout data.
            if let indexOfFavAppliance = self.homeLayouts.firstIndex(where: {$0.layoutFor == .favAppliances}) {
                self.homeLayouts[indexOfFavAppliance].layoutData = []
                self.homeLayouts[indexOfFavAppliance].isDataFetched = true
            }
        }
    }
}

// MARK: Prepared fav static data...
extension HomeViewModel {
    func preparedFavouriteStaticData(){
        let dictData:[String : Any] = ["payload": [
            "content" : [
                [
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_1"
                ],[
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_2"
                ],[
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_3"
                ],[
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_4"
                ],[
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_5"
                ],[
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_6"
                ],[
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_7"
                ],[
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_8"
                ],[
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_9"
                ],[
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_10"
                ],[
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_11"
                ],[
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_12"
                ],[
                    "applianceImage" : "https://s3.ap-south-1.amazonaws.com/doo-assets/dev/appliance/b2bba7d7-cada-4031-ade1-5d0f91d25f1b.png",
                    "applianceId" : 209,
                    "onOffStatus" : false,
                    "active" : true,
                    "favourite" : true,
                    "applianceTypeId" : 4,
                    "userId" : 16,
                    "enterpriseId" : 29,
                    "applianceName" : "Appliance_13"
                ]
            ],
            "pageable" : [
                "totalPages" : 1,
                "pageSize" : 2147483647,
                "numberOfElements" : 1,
                "pageNumber" : 0,
                "totalElements" : 12
            ]
        ], "status": 200]
        
        parseAllFavouriteList(JSON.init(dictData))
    }
    func loadStaticScenesList() {
        /*
        var favouriteDevicesFinalized: [ApplianceDataModel] = []
        
        let favouriteDevices = [
            ApplianceDataModel(id: 1, title: "Master Bed Fan", deviceType: 1, online: true),
            ApplianceDataModel(id: 2, title: "Light 1", deviceType: 2, online: false),
            ApplianceDataModel(id: 3, title: "Mobile Plug", deviceType: 3, online: false),
            ApplianceDataModel(id: 4, title: "Table Light", deviceType: 2, online: false),
            ApplianceDataModel(id: 5, title: "Ceiling Fan", deviceType: 1, online: false),
            ApplianceDataModel(id: 6, title: "Kitchen Light", deviceType: 2, online: true),
            ApplianceDataModel(id: 7, title: "TV Plug", deviceType: 3, online: true),
            ApplianceDataModel(id: 8, title: "TV Plug2", deviceType: 3, online: false),
        ]
        
        if favouriteDevices.count > 7 {
            favouriteDevicesFinalized = Array(favouriteDevices[0...6])
            favouriteDevicesFinalized.append(ApplianceDataModel(isMore: true))
        } else {
            favouriteDevicesFinalized = favouriteDevices
        }

        let layout1 = HomeViewModel.HomeLayouts.init(layoutTitle: localizeFor("favourite_devices"), layoutData: favouriteDevicesFinalized)
        HomeViewModel.homeLayouts.append(layout1)
         */
        let favouriteScenes: [SRSceneDataModel] = []
        if let indexOfScenes = self.homeLayouts.firstIndex(where: {$0.layoutFor == .scenes}) {
            self.homeLayouts[indexOfScenes].layoutData = favouriteScenes
            self.homeLayouts[indexOfScenes].isDataFetched = true
        }
    }
}
