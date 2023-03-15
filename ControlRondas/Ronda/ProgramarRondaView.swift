//
//  CrearRonda.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 05-08-23.
//

import SwiftUI


//la ronda debe tener los nombres de los puntos los qrs, creo que es mejor controlarlo asi, ya que las coordenadas es comoplicado

//primero debemos agregar los puntos. 
struct CrearRonda: View{
    @State var isLoding = true
    @StateObject var modelQRS = ModelQR()
    @State var qrSelected: modelFromFirebase = modelFromFirebase(b64QR: "", Name: "", latitude: "", longuitude: "", documentID: "")
    @State var selectedOptions: [modelFromFirebase] = []
    @StateObject var rondaProgramada = RondasProgramadas()

    @State var Site: String = ""
    @State var NameRound: String = ""
    @State var DateNow = Date()
    @State var fecha: String  = ""
    @State var numberPoint = 0
    @State var showAlert = false
    @State var messageAlert = ""
    @State var Duracion:Double = 0.0
    @State var NamePerson: String = ""
    @State var cliente: String = ""
    @State var site: String = ""
    var array_site_cliente: [String] = ["Cliente joan ","","",""]
    var array_site_1 : [String] = ["","","",""]
    var array_site_2 : [String] = ["","","",""]
    var array_site_3 : [String] = ["","","",""]
    var array_site_4 : [String] = ["","","",""]
    //
//    var fecha: String{
//        var Formmater = DateFormatter()
//        Formmater.dateFormat = "dd/MM/yyyy"
//        return Formmater.string(from: Date())
//    }
    
    var body: some View{
        if isLoding{
            ProgressView("Load..")
            .onAppear{
                modelQRS.getData()
                LoadData()
                
            }
        }else{
            List{
                if modelQRS.arrayQRS.isEmpty{
                    Text("No puedes crear ronda, tienes que crear QRS")
                }else{
                    
                    Menu {
                        ForEach(modelQRS.arrayQRSStruct, id: \.self) { option in
                            Button(action: {
                                if self.selectedOptions.contains(option) {
                                    self.selectedOptions.removeAll(where: { model in
                                        model.Name == option.Name
                                    })
                                } else {
                                    self.selectedOptions.append(option)
                                }
                            }) {
                                HStack {
                                    Text(option.Name)
                                    Spacer()
                                    if self.selectedOptions.contains(option) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text("Selecciona los puntos: \(selectedOptionsString())").lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black)
                        }
                    }.accentColor(.black)
                    

                    

                    //ACA DEBE DE HABER UN FOREACH PARA LOS GUARDIAS QUE SE ENCUENTREN EN FIREBASE.
                    Menu {
                        Picker(selection: $NamePerson,
                            label: EmptyView(),
                            content: {
                                Text("seleccione").tag("")
                                Text("Joan").tag("Joan")
                                Text("maxi").tag("maxi")
                                Text("Juan").tag("juan")
                            }).pickerStyle(.automatic)
                               .accentColor(.white)
                    } label: {
                        HStack{
                            Text("Selecciona un guardia: \(self.NamePerson)")
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black)
                            
                        }
                        
                    }.accentColor(.black)

                

                    


                    HStack(){
                        Text("Nombre de Ronda")
                            .padding(5)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.black).opacity(0.1))
                        TextField("Ronda", text: self.$NameRound).textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    
                    
                    
                    
                    Menu {
                        Picker(selection: $cliente,
                            label: EmptyView(),
                            content: {
                                Text("seleccione").tag("")
                                Text("Joan").tag("Joan")
                                Text("Maxi").tag("maxi")
                                Text("Juan").tag("juan")
                            }).pickerStyle(.automatic)
                               .accentColor(.white)
                    } label: {
                        HStack{
                            Text("Selecciona a una cliente: \(self.cliente)")
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black)
                            
                        }
                        
                    }.accentColor(.black)
                    
                    
                    Menu {
                        Picker(selection: $site,
                            label: EmptyView(),
                            content: {
                                Text("seleccione").tag("")
                                Text("Joan").tag("Joan")
                                Text("Maxi").tag("maxi")
                                Text("Juan").tag("juan")
                            }).pickerStyle(.automatic)
                               .accentColor(.white)
                    } label: {
                        HStack{
                            Text("Selecciona a un site: \(self.site)")
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black)
                            
                        }
                        
                    }.accentColor(.black)
                    
                    
                    
                    VStack {
                        
                        
                        DatePicker("", selection: $DateNow, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .accentColor(.red)
                    
                        //ESTA FECHA HAY QUE MANDAR RECORDAR
                        Text("Fecha seleccionada: \(formatDate(DateNow))")
                            
                    }
                    
                    
                    VStack {
                        
                        
                        DatePicker("Hora seleccionada", selection: $DateNow, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)

    //                    Text("Hora seleccionada: \(formatHour(DateNow))")

                            
                    }
                    
                    VStack{
                        Slider(value: $Duracion, in: 0...120, step: 15)
                        Text("\(Duracion) aproximada")
                    }
                    



                    
                 
                    
                    
                    
                    
                }//fin else
                
                
                


            }.navigationTitle("Crear Ronda")
            .safeAreaInset(edge: .bottom, alignment:.trailing, content: {
                Button {
                    let rondaProgramadaAux = RondaProgramadaModel(fecha:formatDate(DateNow), Hora: formatHour(DateNow), Nombre: self.NameRound, Rondas: selectedOptions, Site: self.Site, Duracion: "\(self.Duracion)", isRealized: false)
    
                    LoadToSendData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        if self.isLoding == false{
                            do {
                                try rondaProgramada.createRound(rondaProgramadaAux)
                                self.messageAlert = "La ronda fue creada con exito"
                                self.showAlert = true
                                print("Ronda creada exitosamente")
                            } catch {
                                print("Error al crear la ronda: \(error)")
                                self.messageAlert = "Ha ocurrido un error en la creacion de la ronda"
                                self.showAlert = true
                            }
                        }
                    }
                    

                    
                } label: {
                    Text("Save")
                        .foregroundColor(.black)
                        .font(.callout)
                        .padding()
                        .background(Circle().fill(.blue))
                }.alert(isPresented: $showAlert) {
                    Alert(title: Text("Importante message"), message: Text(self.messageAlert), dismissButton: .default(Text("Ok")))
                }

            })
        }
        

    }
    
    func LoadData(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.isLoding = false
        }
    }
    
    func LoadToSendData(){
        self.isLoding = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.NameRound = ""
            self.Site = ""
            self.selectedOptions.removeAll()
            self.isLoding = false
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    func formatHour(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func selectedOptionsString() -> String {
        let selectedNames = selectedOptions.map { $0.Name }
        return selectedNames.joined(separator: ", ")
    }
                         
}
struct CrearRonda_Previews: PreviewProvider {
    static var previews: some View {
        CrearRonda()
    }
}


//una ronda son puntos estrategicos.
struct ModelRondaProgramada: Codable{
    var Rondas: [Locations]
    var duracion: String
    
}


struct RondaProgramadaModel: Codable{
    var fecha: String
    var Hora: String
    var Nombre: String
    var Rondas:[modelFromFirebase]
    var Site: String
    var Duracion: String
    var isRealized: Bool //este viene falso por defecto, ya que la ronda no viene realizada.
    var dictionary: [String:Any]{
        return ["Fecha":fecha, "Hora":Hora,"Nombre":Nombre,"Rondas":Rondas.map({ locations in
            return ["latitude": locations.latitude,"longuitude":locations.longuitude,"name":locations.Name]
        }),"Site":Site,"isRealized": false, "Duracion": Duracion]
    }
}
