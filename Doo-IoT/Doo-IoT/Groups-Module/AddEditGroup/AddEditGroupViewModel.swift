//
//  AddEditGroupViewModel.swift
//  Doo-IoT
//
//  Created by Akash Nara on 16/12/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class AddGroupViewModel {
    enum ErrorState { case name, none }
    func validateFields(name: String?) -> (state:ErrorState, errorMessage:String){
        if InputValidator.checkEmpty(value: name){
            return (.name , localizeFor("group_name_is_required"))
        }
        return (.none ,"")
    }
}
