//
//  SmartMainViewModel.swift
//  Doo-IoT
//
//  Created by Akash Nara on 06/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

class SmartMainViewModel {
    var isFromSiri: Bool = false
    enum EnumSiriMenuType: Int, CaseIterable {
        
        //        .bindingRule is removed from first phase. Add .bindingRule in allCases whenever binding rule is added
                static var allCases: [EnumSiriMenuType] {
                    return [.appliances, .scenes]
                }
                /*
                bindingRule is removed from first phase. Add bindingRule in case with bindingRule = 0 whenever binding rule is added
                case bindingRule = 0
                */
                case appliances = 0
                case scenes
                
                var title:String{
                    switch self {
                    /*
                    bindingRule is removed from first phase. Add bindingRule in case whenever binding rule is added
                     */
                    case .appliances:
                        return "Appliances"
                    case .scenes:
                        return localizeFor("scenes")
                    }
                }
                
                var tabSelected: Bool {
                    switch self {
                    /*
                    bindingRule is removed from first phase. Add bindingRule in case whenever binding rule is added
                     */
                    case .appliances:
                        return true
                    default:
                        return false
                    }
                }
                
                var loadXib: UIView? {
                    switch self {
                    /*
                    bindingRule is removed from first phase. Add bindingRule in case whenever binding rule is added
                    
                    */
                    case .appliances:
                        let objSlide:AppliancesViewInAskSiriMainVc = Bundle.main.loadNibNamed("AppliancesViewInAskSiriMainVc", owner: self, options: nil)?.first as!
                        AppliancesViewInAskSiriMainVc
                        return objSlide
                    case .scenes:
                        let objSlide:SceneViewInSmartMainVc = Bundle.main.loadNibNamed("SceneViewInSmartMainVc", owner: self, options: nil)?.first as!
                            SceneViewInSmartMainVc
                        return objSlide
                    }
                }
            }
    enum EnumSmartMenuType:Int, CaseIterable {
        
//        .bindingRule is removed from first phase. Add .bindingRule in allCases whenever binding rule is added
        static var allCases: [EnumSmartMenuType] {
            if let userRole = APP_USER?.selectedEnterprise?.userRole {
                switch userRole {
                case .user:
                    // ON THIS IF REQUIRED TO HIDE SCHEDULER BASED ON USER OR ADMIN ROLE....
                    // return [.scenes]
                    return [.schedule, .scenes]
                default:
                    return [.schedule, .scenes]
                }
            }
            return [.schedule, .scenes]
        }        
        /*
        bindingRule is removed from first phase. Add bindingRule in case with bindingRule = 0 whenever binding rule is added
        case bindingRule = 0
        */
        case bindingRule = -1
        case schedule
        case scenes
        
        var title:String{
            switch self {
            /*
            bindingRule is removed from first phase. Add bindingRule in case whenever binding rule is added
             */
            case .bindingRule:
                return localizeFor("binding_Rule")
            case .schedule:
                return localizeFor("schedule")
            case .scenes:
                return localizeFor("scenes")
            }
        }
        
        var tabSelected: Bool {
            switch self {
            /*
            bindingRule is removed from first phase. Add bindingRule in case whenever binding rule is added
             */
            case .bindingRule:
                return true
            case .schedule:
                return true
            default:
                return false
            }
        }
        
        var loadXib: UIView? {
            switch self {
            /*
            bindingRule is removed from first phase. Add bindingRule in case whenever binding rule is added
            
            */
            case .bindingRule:
                let objSlide:BindingRuleViewInSmartMainVc = Bundle.main.loadNibNamed("BindingRuleViewInSmartMainVc", owner: self, options: nil)?.first as!
                    BindingRuleViewInSmartMainVc
                return objSlide
            case .schedule:
                let objSlide:ScheduleViewInSmartMainVc = Bundle.main.loadNibNamed("ScheduleViewInSmartMainVc", owner: self, options: nil)?.first as! ScheduleViewInSmartMainVc
                return objSlide
            case .scenes:
                let objSlide:SceneViewInSmartMainVc = Bundle.main.loadNibNamed("SceneViewInSmartMainVc", owner: self, options: nil)?.first as!
                    SceneViewInSmartMainVc
                return objSlide
            }
        }
    }
    
    // select rule
    var selectdEnumSmartMenuType: EnumSmartMenuType!
    var selectedEnumSiriMenuType: EnumSiriMenuType!
    // all groupe layout
    var arrrayOfGroup: [EnumSmartMenuType] = []
    var arrayOfSiriGroup: [EnumSiriMenuType] = []
    
    init() {
        preparedSmartMenuArray()
        preparedSiriSmartMenuArray()
    }
    
    func preparedSmartMenuArray(){
        arrrayOfGroup.removeAll()
        /*
        bindingRule is removed from first phase. Add bindingRule in arrrayOfGroup whenever binding rule is added
        arrrayOfGroup.append(.bindingRule)
        */
        arrrayOfGroup.append(.schedule)
        arrrayOfGroup.append(.scenes)
        
        /*
         bindingRule is removed from first phase. Once its added make selectdEnumSmartMenuType to .bindingRule whenever bindingRule needs to be implemented.
        */
        selectdEnumSmartMenuType = .schedule
    }
    
    func preparedSiriSmartMenuArray(){
        /*
        bindingRule is removed from first phase. Add bindingRule in arrrayOfGroup whenever binding rule is added
        arrrayOfGroup.append(.bindingRule)
        */
        arrayOfSiriGroup.append(.appliances)
        arrayOfSiriGroup.append(.scenes)
        
        /*
         bindingRule is removed from first phase. Once its added make selectdEnumSmartMenuType to .bindingRule whenever bindingRule needs to be implemented.
        */
        selectedEnumSiriMenuType = .appliances
    }
}
