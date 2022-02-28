//
//  CustomTabbarView.swift
//  CustomTabbar-SwiftUI
//
//  Created by Kiran Jasvanee on 18/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import SwiftUI
import Combine
import UIKit

class DooTabbarObservable: ObservableObject {
    // 2.
    static let shared = DooTabbarObservable()
    @Published var selection: Int = 0 {
        didSet {
            tabIndexChanged?(selection)
        }
    }
    private var tabIndexChanged: ((Int)->())? = nil
    func indexChanged(_ closure: @escaping (Int)->()) {
        tabIndexChanged = closure
    }
}

struct TabbarAnchorKeyPrefernces: PreferenceKey {
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

struct DooTabbarView: View {

    @ObservedObject var dooTabbarSelection: DooTabbarObservable = DooTabbarObservable.shared
    
    var body: some View {
        
        HStack(alignment: .center) {
            self.item(at: 0, tabbarIconOn: "tabMenuOn", tabbarIconOff: "tabMenuOff", tabbarTitle: localizeFor("menu_tab"))
            self.item(at: 1, tabbarIconOn: "tabHomeOn", tabbarIconOff: "tabHomeOff", tabbarTitle: localizeFor("home_tab"))
            self.item(at: 2, tabbarIconOn: "tabGroupsOn", tabbarIconOff: "tabGroupsOff", tabbarTitle: localizeFor("groups_tab"))
            self.item(at: 3, tabbarIconOn: "tabSmartOn", tabbarIconOff: "tabSmartOff", tabbarTitle: localizeFor("smart_tab"))
        }
        .frame(maxWidth: .infinity, minHeight: 49)
        .padding([.leading, .trailing], 5)
//        .background(
//            GeometryReader { parentGeometry in
//                Rectangle()
//                    .fill(Color(UIColor.systemGray2))
//                    .frame(width: parentGeometry.size.width, height: 0.5)
//                    .position(x: parentGeometry.size.width / 2, y: 1)
//            }
//        )
            .backgroundPreferenceValue(TabbarAnchorKeyPrefernces.self, {
                self.indicator($0)
            })
            .animation(Animation.easeIn(duration: 0.2))
        
    }

    
    private func item(at index: Int, tabbarIconOn: String, tabbarIconOff: String, tabbarTitle: String) -> some View {
        
        CustomTabBarItem(iconNameOn: tabbarIconOn,
                         iconNameOff: tabbarIconOff,
                         label: tabbarTitle,
                         tag: index,
                         selectedTabnWidth: tabbarTitle.widthOfString(usingFont: UIFont.init(name: "Helvetica Neue", size: 14)!)
        )
        .onTapGesture { // 2
                withAnimation(Animation.easeOut(duration: 0.2).delay(0.0)) {
                    self.dooTabbarSelection.selection = index // 3
                    //self.tag = (self.tag == 1) ? 0 : 1
                }
        }
        .anchorPreference(key: TabbarAnchorKeyPrefernces.self, value: .bounds, transform: { view in
            if self.dooTabbarSelection.selection == index {
                return view
            }else{
                return nil
            }
        })
    }
    
    private func indicator(_ bounds: Anchor<CGRect>?) -> some View {
        GeometryReader { proxy in
            if bounds != nil {
                Rectangle()
                    .fill(Color.grayTabbarBackground)
                    .cornerRadius(30)
                    .frame(width: proxy[bounds!].width, height: proxy[bounds!].height + 8)
                    .offset(x: proxy[bounds!].minX, y: -(proxy[bounds!].minY-4))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .animation(.interpolatingSpring(mass: 1, stiffness: 170, damping: 16.0, initialVelocity: 5))
                    //.animation(.interpolatingSpring(mass: 1.0, stiffness: 150.0, damping: 17, initialVelocity: 0))
            }
        }
    }
}

struct TabbarView_Previews: PreviewProvider {
    static var previews: some View {
        DooTabbarView()
            .previewLayout(.fixed(width: 446, height: 49))
    }
}

