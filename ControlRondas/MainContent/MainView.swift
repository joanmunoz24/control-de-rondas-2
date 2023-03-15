//
//  MainView.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 06-05-23.
//

import SwiftUI

struct MainView: View {
    
    let widthTotal = UIScreen.main.bounds.width
    @State var load = true
    @State var showMenu = false
    @State var value : Float = 0
    @State var showAlertLogOut: Bool = false
    @State var showSites = false
    
    
    @Binding var isLoged: Bool
    @Binding var name: String
    @Binding var username: String
    @Binding var isAdmin: String
    
    
    @Binding var photoB64: String
    @Binding var Site: [String]
    @Binding var Phone: String
    @Binding var DocumentId: String
    
    @StateObject var PruebaFirebase = ViewModel()
    
  
    
    init(isLoged: Binding<Bool>,name:Binding<String>,username:Binding<String>,isAdmin:Binding<String>,photoB64: Binding<String>,Site: Binding<[String]>,Phone: Binding<String>, DocumentId:Binding<String>){
//        ,photoB64: Binding<String>,Site: Binding<[String]>,Phone: Binding<String>, DocumentId:Binding<String>
        self._isLoged = isLoged
        self._name = name
        self._username = username
        self._isAdmin = isAdmin
        self._photoB64 = photoB64
        self._Site = Site
        self._Phone = Phone
        self._DocumentId = DocumentId
        
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.backgroundColor = UIColor(.blue)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance//
        UINavigationBar.appearance().tintColor = .black


    }
    var body: some View {
        NavigationView {
            ZStack{
                ZStack{
                    
                    
                    if load{
                        ProgressView("Processing")// 1
                            .tint(.cyan)
                            .foregroundColor(.black)
                            .navigationBarTitleDisplayMode(.inline)
                            .onAppear {
                                loadView()
                            }
                    }else{
                        VStack(alignment: .center,spacing: 20){
                            
                            if self.isAdmin == "0"{
                                VigilantView()
                            }else{

                                AdminView()
                                
                            }
                            
                            
                            Button {
                                self.showAlertLogOut = true
                            } label: {
                                ButtonMenuPrincipal(text: "Log out", icono: "lock.open", imgSystem: true, width: 25, height: 30)
                            }.buttonStyle(VerdeButtonStyle())
                                .alert("Log out", isPresented: $showAlertLogOut) {
                                    Button("No", role: .cancel, action: {})
                                    
                                    Button("Yes", role: .destructive, action: {
                                        withAnimation {
                                            isLoged = false
                                            
                                            UserDefaults.standard.removeObject(forKey:"Name")
                                            UserDefaults.standard.removeObject(forKey: "Username")
                                            UserDefaults.standard.removeObject(forKey: "isAdmin")
                                            UserDefaults.standard.removeObject(forKey: "isLogged?")
                                            UserDefaults.standard.removeObject(forKey: "DocumentId")
                                            UserDefaults.standard.removeObject(forKey: "photoB64Profile")
                                            UserDefaults.standard.removeObject(forKey: "Phone")
                                            UserDefaults.standard.removeObject(forKey: "Site")
                                            
                                            
                                        }
                                    })
                                    
                                } message: {
                                    Text("Are you sure?")
                                }
                            
                            
                            
                            
                            
                            
                            
                        }

                        
                    }
                    
                    
                    VStack{
                        
                        if self.showMenu {
                            HStack{
                                VStack(alignment : .leading, spacing: 20) {
                                    HStack(spacing: 20){
                                        if self.photoB64.isEmpty{
                                            Image(systemName: "person.circle.fill")
                                                .font(.title)
                                        }else{
                                            Image(base64String: self.photoB64)?.resizable()
                                                .frame(width: 100, height: 100,alignment: .leading)
                                                .cornerRadius(20)
                                                
                                        }
                                            
                                        VStack(alignment: .leading, spacing: 12) {
                                            if self.isAdmin == "0"{
                                                Text("Guardia").bold().italic()
                                            }else{
                                                Text("Admin").bold().italic()
                                            }
                                            Text(username)
                                                .foregroundColor(Color.black)
                                                .fontWeight(.bold)
                                            Text(self.Phone)
                                                .foregroundColor(Color.black)
                                            
                                        }
                                    }.padding(.top, 100)
                                        Divider()
                                        .background(Color.black)
                                    HStack {
                                        NavigationLink(destination: ProfileView(Username: self.$username, Nombre: self.$name, photo: self.$photoB64, Phone: self.$Phone, documentID: self.$DocumentId)){
                                            Image(systemName: "person")
                                                .foregroundColor(.gray)
                                                .imageScale(.large)
                                            Text("Perfil")
                                                .foregroundColor(.black)
                                                .font(.headline)
                                        }
                                    }
                                    HStack{
                                        
                                            Button{
                                                
                                            } label: {
                                                Image(systemName: "gear")
                                                    .foregroundColor(.gray)
                                                    .imageScale(.large)
                                                Text("Cerrar Sesión")
                                                    .foregroundColor(.black)
                                                    .font(.headline)
                                            }
                                    }

                                    Spacer()
                                }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .edgesIgnoringSafeArea(.all)
              
//                                Spacer()
                                
                                Button(action:{
                                    self.showMenu.toggle()
                                }){
                                    GeometryReader { geometry in
                                        VStack(alignment:.leading){
                                            Text("")
                                        }
                                            .frame(width: geometry.size.width,
                                               height: nil,
                                               alignment: .topLeading)
                                            
                                            
                                    }
                                }.frame(maxWidth: 90, alignment: .leading)
                                    .background(Color.black.opacity(0.5))
                                
                            }
                        }
                        if(self.showSites){
                            VStack{
                                Button(action:{
                                    self.showSites.toggle()
                                }){
                                    GeometryReader { geometry in
                                        VStack {
                                            Text("")
                                        }
                                            .frame(width: geometry.size.width,
                                               height: nil,
                                               alignment: .topLeading)
                                            
                                    }
                                }.frame(maxWidth: .infinity , alignment: .leading)
                                Spacer()
                            }.background(Color(UIColor.label.withAlphaComponent(0.2))
                            .edgesIgnoringSafeArea(.all))
                        }
                        
                    }
                        
                    

                    
                    
                    
                }.navigationBarTitle("Control de rondas",displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action:{
                                withAnimation {
                                        self.showMenu.toggle()
                                   }
                                
                            }){
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(.black)
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {

                            if self.isAdmin == "0"{
                                Button(action:{
                                    withAnimation {
                                            self.showSites.toggle()
                                       }
                                    
                                }){
                                    Image(systemName: "filemenu.and.selection")
                                        .foregroundColor(.black)
                                }
                            }else{
                                Text("Admin").bold().italic()
                            }

                        }
                    }
            }
            
            
 
                
        }
    }
    
    @ViewBuilder
    func AdminView()-> some View{
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
        
        LazyVGrid(columns: columns, spacing: 16) {
            NavigationLink(destination: CrearRonda()) {
                ButtonMenuPrincipal(text: "Programar Ronda", icono: "location.circle", imgSystem: true, width: 25, height: 30)
                    
            }.buttonStyle(VerdeButtonStyle())

            NavigationLink(destination: RondasTerminadasView(isAdmin: true)) {
                ButtonMenuPrincipal(text: "Rondas Terminadas", icono: "location.circle", imgSystem: true, width: 25, height: 30)
            }.buttonStyle(VerdeButtonStyle())
            
            NavigationLink(destination: CreateQR()) {
                ButtonMenuPrincipal(text: "Crear QR", icono: "qrcode.viewfinder", imgSystem: true, width: 25, height: 30)
            }.buttonStyle(VerdeButtonStyle())
            
            NavigationLink(destination: ShowQRS()) {
                ButtonMenuPrincipal(text: "Mostrar QRS", icono: "qrcode", imgSystem: true, width: 25, height: 30)
            }.buttonStyle(VerdeButtonStyle())
            
//            NavigationLink(destination: RondaViewPrueba()) {
//                ButtonMenuPrincipal(text: "PRUEBARONDANNUEVA", icono: "location.circle", imgSystem: true, width: 25, height: 30)
//            }.buttonStyle(VerdeButtonStyle())
        }

    }
    
    
    @ViewBuilder
    func VigilantView()-> some View{
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
        
        LazyVGrid(columns: columns, spacing: 16) {
            NavigationLink(destination: RondaViewPrueba()) {
                ButtonMenuPrincipal(text: "Control de rondas", icono: "location.circle", imgSystem: true, width: 25, height: 30)
            }.buttonStyle(VerdeButtonStyle())
            NavigationLink(destination: RondasTerminadasView(isAdmin: false)) {
                ButtonMenuPrincipal(text: "Rondas Realizadas", icono: "location.circle", imgSystem: true, width: 25, height: 30)
            }.buttonStyle(VerdeButtonStyle())
        }

    }
    
    func ButtonMenuPrincipal(text : String, icono : String, imgSystem : Bool, width: CGFloat, height: CGFloat) -> some View {
            Group(){
                HStack{
                        if(imgSystem){
                            Image(systemName: "\(icono)").resizable()
                                .frame(width: width, height: height,alignment: .leading)
                                .aspectRatio(contentMode: ContentMode.fit)
                        }else{
                            Image("\(icono)").resizable()
                            .frame(width: width, height: height)
                        }
                    Spacer()
                    Text("\(text)")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20))
                    Spacer()
                }

                }
        

    }

    
    func loadView(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeIn) {
                self.load = false
            }
        }
    }
}



//una ronda tiene: site, duracion, hora, fecha, punto


struct selectSite: View{
    @Binding var selectSite: String
    var body: some View{
        Text("")
    }
}



struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(isLoged: .constant(true), name: .constant(""), username: .constant(""), isAdmin: .constant("0"), photoB64: .constant(""), Site: .constant(["12","23","24"]), Phone: .constant(""), DocumentId: .constant(""))
    }
}
