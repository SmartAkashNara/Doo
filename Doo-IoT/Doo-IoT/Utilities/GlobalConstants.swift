//
//  GlobalConstants.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 20/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

var TABBAR_INSTANCE: UITabBarController? = nil
var COUNTRY_SELECTION_VIEWMODEL = CountrySelectionViewModel() // Country selection work gets done at many places. Keeping globally, because data holding by it is reqally important.

var ENTERPRISE_LIST = [EnterpriseModel]() // Managing an Enterprises list globally. Enterprises are where your home automation internal stuff works

weak var COUNT_DOWN_VIEW: OTPCountdown? = nil // Countdown shown while OTP send...

var API_LOADER = GenericLoaderView()
let APPLIENCE_ON_OFF_UPDATE_STATUS = "APPLIENCE_ON_OFF_UPDATE_STATUS"
let UPDATE_APPLIENCE_FAVOURITE = "UPDATE_APPLIENCE_FAVOURITE"
let GATEWAY_STATUS_CHANGE = "GATEWAY_STATUS_CHANGE"
let APPLIENCE_ONLINE_OFFLine_UPDATE_STATUS = "APPLIENCE_ONLINE_OFFLine_UPDATE_STATUS"
let alexaURLSchema = "alexa://app"
let REFRESH_SCENE_LIST_TO_CHECK_SIRI_SHORTCUTS = "REFRESH_SCENE_LIST_TO_CHECK_SIRI_SHORTCUTS"
