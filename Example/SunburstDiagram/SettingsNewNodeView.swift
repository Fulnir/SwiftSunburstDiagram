//
//  SettingsNewNodeView.swift
//  SunburstDiagramDemo
//
//  Created by Ludovic Landry  on 6/18/19.
//  Copyright © 2019 Ludovic Landry. All rights reserved.
//

import SwiftUI

struct SettingsNewNodeView: View {
    var body: some View {
        Text("This node is not editable.")
    }
}

#if DEBUG
struct SettingsNewNodeView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsNewNodeView()
    }
}
#endif
