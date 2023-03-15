//
//  ProfileView.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 12-08-23.
//

import SwiftUI

struct ProfileView: View {
    @Binding var Username: String
    @Binding var Nombre: String
    @Binding var photo: String
    @Binding var Phone: String
    @Binding var documentID: String
    
    @State var showCamera = false
    @State var sourcetype: UIImagePickerController.SourceType = .camera
    @State var message = ""
    @State var showAlert = false
    @State var Loading = false
    @State var isOk = false
    @StateObject var sendData = UserModel()
    
    var body: some View {
        ZStack{
            if self.Loading{
                ProgressView("Loading")
                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                    .frame(width: 200,height: 200)
                    .background(Color.gray.opacity(0.5))
                    .zIndex(1)
            }
            VStack{
                    ScrollView{
                        Text("Tu Perfil")
                            .foregroundColor(.white)
                            .bold()
                            .padding(.top)
                            .font(.largeTitle)
                        
                        if self.photo.isEmpty{
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                        }else{
                            Image(base64String: self.photo)?.resizable()
                                .frame(width: 200, height: 200,alignment: .leading)
                                .cornerRadius(20)
                            
                        }
                        
                        HStack{
                            Spacer()
                            Button {
                                self.showCamera = true
                                self.sourcetype = .camera
                            } label: {
                                Text("Take Photo")
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Rectangle().fill(.cyan))
                                    .shadow(color: Color.green.opacity(0.3), radius: 20)
                                    .border(.green,width: 2)
                                    .cornerRadius(10)
                            }.sheet(isPresented: $showCamera) {
                                ImagePickerView(selectedImage: self.$photo, sourceType: $sourcetype)
                                
                                
                            }
                            
                            Spacer(minLength: 10)
                            
                            Button {
                                self.showCamera = true
                                self.sourcetype = .photoLibrary
                            } label: {
                                Text("Select Photo")
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Rectangle().fill(.cyan))
                                    .shadow(color: Color.green.opacity(0.3), radius: 20)
                                    .border(.green,width: 2)
                                    .cornerRadius(10)
                            }.sheet(isPresented: $showCamera) {
                                ImagePickerView(selectedImage: self.$photo, sourceType: $sourcetype)
                            }
                            Spacer()
                            
                        }
                        
                        VStack{
                            Field(label: "DocumentId", value: self.$documentID).disabled(true)
                            Field(label: "Nombre", value: self.$Nombre)
                            Field(label: "Username", value: self.$Username)
                            Field(label: "Phone", value: self.$Phone)
                            
                        }.padding()
                        
                        
                        
                        Button {
                            
                            
                            let usermodel = Profile(nombre: self.Nombre, username: self.Username, photoB64: self.photo, phone: self.Phone)
                            
                            loadingsendData()
                            
                            
                            let isSend = sendData.editData(self.documentID, usermodel)
//                            let isSend = true
                        
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                                if self.Loading == false{
                                    if isSend{
                                        self.message = "Ha salido todo con exito"
                                        self.showAlert = true
                                        UserDefaults.standard.setValue(self.Nombre, forKey: "Name")
                                        UserDefaults.standard.setValue(self.Username, forKey: "Username")
                                        UserDefaults.standard.setValue(self.Phone, forKey: "Phone")
                                        UserDefaults.standard.setValue(self.photo, forKey: "photoB64Profile")
                                    }else{
                                        self.message = "Ha ocurrido un error"
                                        self.showAlert = true

                                    }
                                }
                            }



                            
                        } label: {
                            Text("GUARDAR")
                                .foregroundColor(.white)
                                .padding()
                                .background(Rectangle().fill(.cyan))
                                .shadow(color: Color.green.opacity(0.3), radius: 20)
                                .border(.green,width: 2)
                                .cornerRadius(10)
                        }.alert(isPresented: $showAlert) {
                            Alert(title: Text("Importante message"), message: Text(self.message), dismissButton: .default(Text("Ok")))
                        }
                        
                    }.background(Color(hex: "2898ee"))
                    //                .background(.blue)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.green, lineWidth: 1)
                            
                        )
                        .padding(20)
                
                
                
                
            }.background(Color(hex: "107acc"))
            
        }
    }
    
    func loadingsendData(){
        self.Loading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.Loading = false
            
        }
    }
}


struct Field: View{
    var label: String
    @Binding var value: String
    
    
    var body: some View{
        VStack(alignment:.leading, spacing: 10){
            Text(label)
                
                .padding(5)
                
            TextField(label, text: self.$value)
                .font(.headline)
            
            Divider()
                .frame(height: 1)
                .padding(.horizontal, 30)
                .background(Color.white)
        }.foregroundColor(.white)
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(Username: .constant(""), Nombre: .constant(""), photo: .constant(""), Phone: .constant(""), documentID: .constant("12343"))
    }
}
