//
//  KindledWidgetBundle.swift
//  KindledWidget
//
//  Created by Luka on 28.06.26.
//

import WidgetKit
import SwiftUI

@main
struct KindledWidgetBundle: WidgetBundle {
    var body: some Widget {
        KindledWidget()
        KindledWidgetControl()
    }
}
