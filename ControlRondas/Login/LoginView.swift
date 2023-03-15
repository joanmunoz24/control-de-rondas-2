//
//  LoginView.swift
//  CurrentLocation
//
//  Created by Joan Muñoz on 06-05-23.
//

import SwiftUI
import CryptoKit
import Firebase



struct LoginView: View {
    @State var isAnimating = false
    @State var isAnimatingHeaderUserName = false
    @State var isAnimatingHeaderPassword = false
    @State var usernameTextField = ""
    @State var passwordTextField = ""
    @State var showAlertIncorrectUser = false
    
    @FocusState var UsernameFocus: Bool
    @FocusState var PasswordFocus: Bool
    
    var db = Firestore.firestore()
    
    @Binding var isLogged: Bool
    @Binding var name: String
    @Binding var username: String
    @Binding var isAdmin: String
    
    @Binding var photoB64: String
    @Binding var Site: [String]
    @Binding var Phone: String
    @Binding var DocumentId: String
    
    var body: some View {
        GeometryReader{
            let size = $0.size
            
            VStack(spacing: 10){
                VStack(){
                    VStack(){
                        Image("LogoApp").resizable().scaledToFit()
                    }
                    
                    //USERNAME
                    VStack(alignment: .leading, spacing: 5){
                        Text("Username")
                            .font(Font.system(size: 10))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(
                                LinearGradient(colors: [.red,.cyan], startPoint: isAnimatingHeaderUserName ? .leading : .trailing, endPoint: .trailing)
                                .animation(.linear(duration: 3).repeatForever(autoreverses: true),value: isAnimatingHeaderUserName)
                                .onAppear { isAnimatingHeaderUserName.toggle() })
                        
                        TextField("Enter your username", text: $usernameTextField)
                            .font(Font.system(size: 15))
                            .foregroundColor(.black)
                            .font(.largeTitle)
                            .padding(10)
                            .background(Color.white)
                            .overlay(alignment: .bottom){
                                if UsernameFocus == true{
                                    Rectangle()
                                         .frame(height: 4)
                                         .foregroundColor(Color.black)
                              

                                }
                                 
                            }
                            .animation(.linear(duration: 1), value: UsernameFocus)

                            
    
                    }.padding(.vertical,5)
                        .focused($UsernameFocus)
                    
                    
                    
                    //PASSWORD
                    VStack(alignment:.leading, spacing: 5){
                        Text("Password")
                            .font(Font.system(size: 10))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(
                                LinearGradient(colors: [.red,.cyan], startPoint: isAnimatingHeaderPassword ? .leading : .trailing, endPoint: .trailing)
                                .animation(.linear(duration: 3).repeatForever(autoreverses: true),value: isAnimatingHeaderPassword)
                                .onAppear { isAnimatingHeaderPassword.toggle() })
                        
                        TextField("Enter your Password", text: $passwordTextField)
                            .font(Font.system(size: 15))
                            .foregroundColor(.black)
                            .font(.largeTitle)
                            .padding(10)
                            .background(Color.white)
                            .overlay(alignment: .bottom){
                                if PasswordFocus == true{
                                    Rectangle()
                                         .frame(height: 4)
                                         .foregroundColor(Color.black)
                              

                                }
                                 
                            }
                            .animation(.linear(duration: 1), value: PasswordFocus)
                    }
                    
                    Button {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                         impactMed.impactOccurred()
                        
                        let passEncript = hashPassword(password: passwordTextField.lowercased())
                        
                        Task{
                            if await self.isInFirestore(Name: usernameTextField.lowercased(), Password: passEncript) == 1{
                                print("hola que tal")
                                self.getDataFromFirestore(Name: usernameTextField.lowercased(), Password: passEncript)
                                isLogged = true
                            }else{
                                isLogged = false
                                showAlertIncorrectUser = true
                                //aca debe de ir el alert de que no funciono, hay algo malo del login.
                            }
                        }
//
//
//
//
                        
                        
//
//                        if usernameTextField.lowercased() == "joan" && passwordTextField.lowercased() == "1234" {
//                            print("Has sido logeado con exito")
                            
//                            UserDefaults.standard.setValue(isLogged, forKey: "isLogged?")
//
//                        }
                    } label: {
                        Text("SIGN IN")
                    }.buttonStyle(GrowingButton(color: .indigo,width: 200,height: 10))
                        .padding(.top)
                        .alert(isPresented: self.$showAlertIncorrectUser) {
                            Alert(title: Text("Error"),
                                    message: Text("Nombre de usuario o contraseñas incorrectos"),
                                    dismissButton: .default(Text("OK"), action: {}))
                        }

                }.padding(.horizontal)
                    .frame(width: size.width/1.1, height: size.height/1.3,alignment: .center)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    
            }
            .frame(width: size.width, height: size.height,alignment: .center)
                
        } .background(
            LinearGradient(colors: [.red,.cyan,.indigo,.blue], startPoint: isAnimating ? .bottomLeading : .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true),value: isAnimating)
                .onAppear { isAnimating.toggle() }
        )

    }
    
    
    //Funcion para poder realizar el hash de la contraseña.
    func hashPassword(password: String) -> String {
        if let passwordData = password.data(using: .utf8) {
            let hashed = SHA256.hash(data: passwordData)
            let hashedString = hashed.compactMap { String(format: "%02x", $0) }.joined()
            return hashedString
        } else {
            // Manejar el error si la conversión de la contraseña a datos falla
            return ""
        }
    }
    
    
    
    func isInFirestore(Name:String, Password:String) async -> Int{
        let collection = try! await db.collection("Users")
            .whereField("Username", isEqualTo: "\(Name)")
            .whereField("Password", isEqualTo: "\(Password)")
            .getDocuments().count
        
        return collection
    }
    
    func getDataFromFirestore(Name:String, Password:String){
        let collection = db.collection("Users")
            .whereField("Username", isEqualTo: "\(Name)")
            .whereField("Password", isEqualTo: "\(Password)")
        
        collection.getDocuments { snap, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let snapshot = snap {
                
                DispatchQueue.main.async {
                    for document in snapshot.documents{
                        let data = document.data()
                        self.DocumentId = document.documentID
                        UserDefaults.standard.setValue(self.DocumentId, forKey: "DocumentId")
                        self.name = data["Name"] as! String
                        UserDefaults.standard.setValue(self.name, forKey: "Name")
                        self.username = data["Username"] as! String
                        UserDefaults.standard.setValue(self.username, forKey: "Username")
                        self.isAdmin = data["isAdmin"] as! String
                        UserDefaults.standard.setValue(self.isAdmin, forKey: "isAdmin")
                        self.Phone = data["Phone"] as? String ?? "No phone"
                        UserDefaults.standard.setValue(self.Phone, forKey: "Phone")
                        self.photoB64 = data["photoB64"] as? String ?? ""
                        UserDefaults.standard.setValue(self.photoB64, forKey: "photoB64Profile")
                        self.Site = data["Site"] as? [String] ?? [""]
                        UserDefaults.standard.setValue(self.Site, forKey: "Site")
                        UserDefaults.standard.setValue(true, forKey: "isLogged?")
                    }
                }
                
            }
        }
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView(isLogged: .constant(false))
//    }
//}


struct GrowingButton: ButtonStyle {
    var color: Color
    var width: CGFloat
    var height: CGFloat
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: width, height: height)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            
    }
}
