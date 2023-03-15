//
//  UsersView.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 14-08-23.
//

import SwiftUI

struct CreateUserView: View {
    @State var Name:String = ""
    @State var Username: String = ""
    @State var Password: String = ""
    @State var Site: [String] = []
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct UsersView_Previews: PreviewProvider {
    static var previews: some View {
        CreateUserView()
    }
}
