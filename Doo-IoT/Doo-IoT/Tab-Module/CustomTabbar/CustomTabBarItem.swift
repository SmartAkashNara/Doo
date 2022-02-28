//
//  CustomTabBarItem.swift
//  CustomTabbar-SwiftUI
//
//  Created by Kiran Jasvanee on 16/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import SwiftUI

struct CustomTabbarItemFrameModifier: ViewModifier {
    var isSelected: Bool
    var selectedTabWidth: CGFloat
    func body(content: Content) -> some View {
    Group {
        if self.isSelected {
            content.frame(width: selectedTabWidth + 30)
        }else{
            content.frame(maxWidth: .infinity)
        }
    }
  }
}

extension View {
    func customTabbarItemFraming(_ value: Bool,_ selectedTabWidth: CGFloat) -> some View {
        self.modifier(CustomTabbarItemFrameModifier(isSelected: value, selectedTabWidth: selectedTabWidth))
    }
}

struct CustomTabBarItem: View {
    let iconNameOn: String
    let iconNameOff: String
    let label: String
    var tag: Int // 2
    let selectedTabnWidth: CGFloat // 1
    
    @ObservedObject var dooTabbarSelection: DooTabbarObservable = DooTabbarObservable.shared
        
    var body: some View {
        HStack() {
            Image(self.dooTabbarSelection.selection == self.tag ? iconNameOn : iconNameOff)
                .resizable()
                .frame(width: 20.0, height: 20.0)
            
            if self.dooTabbarSelection.selection == self.tag {
                // Changing selection value.
                    Text(label)
                        .font(.caption)
                        .transition(.scale)
            }
        }
        .padding(5)
        .font(Font.Poppins.medium(14))
        .foregroundColor(fgColor()) // 4
        .foregroundColor(Color(UIColor.systemGray))
            .customTabbarItemFraming(self.dooTabbarSelection.selection == self.tag, self.selectedTabnWidth)
        .contentShape(Rectangle()) // 3
        
    }
    
    private func fgColor() -> Color {
        return self.dooTabbarSelection.selection == tag ? Color.tabbarTitle : Color.tabbarTitle
    }
}

struct CustomTabBarItem_Previews: PreviewProvider {
    static var selection: Int = 0
    static var selectionBinding = Binding<Int>(
        get: { selection }, set: { selection = $0 }
    )
    
    static var previews: some View {
        CustomTabBarItem(iconNameOn: "clock.fill", iconNameOff: "clock.fill", label: "Recents", tag: 0, selectedTabnWidth: 100)
        .previewLayout(.fixed(width: 80, height: 80))
    }
}
