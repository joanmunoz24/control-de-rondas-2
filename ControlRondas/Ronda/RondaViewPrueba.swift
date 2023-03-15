//
//  RondaViewPrueba.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 09-08-23.
//

import SwiftUI
import MapKit
import Foundation
import CoreLocation
import Combine
import CodeScanner
import Firebase
import FirebaseFirestoreSwift
import AVFoundation
import UniformTypeIdentifiers

struct RondaViewPrueba: View {
    @StateObject var object = RondasProgramadas()
    @State var LoadView = true
    @State var Refresh = false
    
    var body: some View {
        
        List{
            if LoadView{
                ProgressView {
                    Text("Loading...")
                }.frame(width: getScreenBounds().width)
                    .tint(.blue)
            }else{
                if object.Rondas.isEmpty{
                    VStack(alignment:.center){
                        Text("No rondas")
                    }
                 
                }else{
                    ForEach(self.object.Name.indices, id:\.self){i in
                            NavigationLink {
                                RondaViewPoints(Rondas: object, indice: i)
                            } label: {
                                VStack(alignment:.leading)
                                {
                                    Text("\(self.object.Name[i])")
                                        .font(.title)
                                        .bold()
                                    Text("Inicio \(self.object.Hora[i])")
                                        .font(.headline)
                                        .bold()
                                    Text("Duracion \(self.object.Duracion[i]) min")
                                    Text(self.object.isRealizedRound[i] ? "Realizado" : "Ronda Pendiente").foregroundColor(self.object.isRealizedRound[i] ? .green : .red)
                                }
                            }

                        }
                }
            }

            
        }.onAppear{
            self.LoadView = true
            object.getData()
            loadView()
            print("Ha aparecido esto")
        }
    }
    
    
    func loadView(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            self.LoadView = false
        }
    }
    

}


//VER SI MANDAR INDICE O MANDAR EL DATO DE UNA.
struct RondaViewPoints: View{
    @Environment(\.dismiss) var dismiss

    
    @ObservedObject var Rondas: RondasProgramadas
    var indice: Int
    
    @State private var locationManager = CLLocationManager()
    @State private var delegate = LocationDelegate()
    @State private var latitude:CLLocationDegrees = 0.0
    @State private var lon:CLLocationDegrees = 0.0
    var locations: CLLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    @State var homeLocation:[Pin] = []
    @State var region:MKCoordinateRegion
    @State var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @State var initRound = false
    
    var timerHour = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    var dateFormatter: DateFormatter {
        let fmtr = DateFormatter()
        fmtr.dateFormat = "dd/MM/yyyy, HH:mm"
        
        return fmtr
    }
    
    var dateToday: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }
    
    @State var userRealized = UserDefaults.standard.string(forKey: "Name") ?? ""
    
    @State var TimeStr = ""
    @State var currentDate = Date.now
    
    @State var showAlertOmmited = false
    @State var showScanner = false
    @State var showAlert:Bool = false
    @State var alertMessage = ""
    @State var messageOfQR = ""
    @State var nameOfQR = ""
    
    @State var latFirebase:CLLocationDegrees = 0.0
    @State var lonFirebase:CLLocationDegrees = 0.0
    @State var nameFirebase = ""
    @State var currentIndex = 0
    
    @State private var isShowingImagePicker = false
    
    @State var sourcetype: UIImagePickerController.SourceType = .camera

    @State private var timerTime: Timer?
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0.0
    @State private var isRunning = false

    
    init(Rondas: RondasProgramadas, indice: Int) {
        self.Rondas = Rondas
        self.indice = indice
        _region = State(initialValue: MKCoordinateRegion(center: locations.coordinate, latitudinalMeters: 500, longitudinalMeters: 500))
    }
    

    
    
    var body: some View{
        VStack(alignment: .leading){
            
            
            if initRound{
                ZStack(alignment: .top) {
                    
                    VStack(spacing: 10){
                        Text("Tiempo transcurrido: \(elapsedTime, specifier: "%.2f") segundos")
                            .font(.title)

                        if showAlert == true{
                                MostrarAlerta().zIndex(2)
                            }
                    
                    
                        ForEach(Rondas.Rondas[indice].indices,id:\.self) { i in
                            var namePoint = self.Rondas.Rondas[indice][i].name
                            var latitude = CLLocationDegrees(self.Rondas.Rondas[indice][i].latitude)
                            var longuitude = CLLocationDegrees(self.Rondas.Rondas[indice][i].longuitude)

                            HStack(spacing: 0){

                                if self.Rondas.isOmmited[indice][i] == true{
                                    Text("OM")
                                        .foregroundColor(.red)
                                        .bold()
                                        .frame(width: getScreenBounds().width*0.1)
                                }else{

                                    Text(self.Rondas.isRealized[indice][i] ? "Ok" : "PDT")
                                        .foregroundColor(self.Rondas.isRealized[indice][i] ? .green : .black)
                                        .bold()
                                        .frame(width: getScreenBounds().width*0.1)
                                }



                                Button {

                                    //se deben de crear las variables de esta manera, ya q al entrar en otro contexto en el lector de qr, solamente toma los valores del primer indice

                                    self.nameFirebase = namePoint
                                    self.lonFirebase = longuitude!
                                    self.latFirebase = latitude!
                                    self.currentIndex = i
                                    self.showScanner = true
                                    

                                } label: {
                                    Text(namePoint)
                                        .foregroundColor(.black)
                                        .frame(width: getScreenBounds().width*0.6)
                                        .background {
                                            Color.black.opacity(0.3)
                                        }
                                        .cornerRadius(10)

                                }.disabled(self.Rondas.isOmmited[indice][i])
                                    .opacity(self.Rondas.isOmmited[indice][i] ? 0.1 : 1)

                                .sheet(isPresented: $showScanner) {
                                    CodeScannerView(codeTypes: [.qr], completion: { result in
                                        if case let .success(code) = result{
                                            
                                            let arrayMessage = code.string.split(separator: ",")
                                            self.nameOfQR = String(arrayMessage[0])
                                            self.latitude = Double(arrayMessage[1])!
                                            self.lon = Double(arrayMessage[2])!

                                            //se realiza la multiplicacion para poder ir realizando los ajustes, un ajuste de 5 metros es mas que suficiente
                                            //MARK: Al parecer con el ajuste de los 5 metros se puedo realizar un buen ajuste.
                                            let margin: CLLocationDegrees = 0.000009 * 5   // Aproximadamente 1 metro en términos de latitud y longitud

                                            let latMinus = self.latFirebase.rounded(to: 6) - margin
                                            let latMed = self.latitude.rounded(to: 6)
                                            let latMax = self.latFirebase.rounded(to: 6) + margin
                                            let isCorrect = latMinus <= latMed && latMax >= latMed ? "si" : "no"
                                            let jsjs = ""

                                            if (self.latFirebase - margin <= self.latitude && self.latFirebase + margin >= self.latitude) &&
                                                (self.lonFirebase - margin <= self.lon && self.lonFirebase + margin >= self.lon && self.nameOfQR == self.nameFirebase){


                                                withAnimation {
                                                    Rondas.isRealized[indice][self.currentIndex] = true
                                                    print("son los mismo puntos")
                                                    self.showScanner = false
                                                    self.showAlert = true
                                                    self.alertMessage = "Se ha realizado con exito el punto"

                                                }
                                            }else{

                                                self.showScanner = false
                                                self.showAlert = true
                                                print("No son los mismos puntos")
                                                self.alertMessage = "No se puedo realizar el punto"
                                            }




                                        }

                                    }
                                    )
                                }


                                Button {
                                    withAnimation {
                                        Rondas.haveComment[indice][i] = true
                                    }
                                } label: {
                                    Image(systemName: "text.bubble")
                                        .foregroundColor(.black)
                                        .frame(width: getScreenBounds().width*0.1)
                                        .background {
                                            Color.white
                                        }
                                        .cornerRadius(10)
                                }





                                Button {
                                    print("has presionda el valor de agregar imagen en \(namePoint)")
                                    
                                    withAnimation {
                                        self.currentIndex = i
                                        print("has presionda el valor de agregar imagen en \(self.Rondas.Name[currentIndex])")
                                        self.isShowingImagePicker.toggle()
                                        self.sourcetype = .camera
                                    }

                                } label: {
                                    Image(systemName: "camera")
                                        .foregroundColor(.black)
                                        .frame(width: getScreenBounds().width*0.1)
                                        .background {
                                            Color.white
                                        }
                                        .cornerRadius(10)
                                }
                                .sheet(isPresented: $isShowingImagePicker) {
                                    
                                    ImagePickerView(selectedImage: self.$Rondas.photoB64[indice][self.currentIndex], sourceType: $sourcetype)


                                }



                                //boton para omitir la ronda
                                Button {
                                    withAnimation {
                                        self.showAlertOmmited = true
                                        self.currentIndex = i
                                        
                                    }

                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.black)
                                        .frame(width: getScreenBounds().width*0.1)
                                        .background {
                                            Color.white
                                        }
                                        .cornerRadius(10)

                                }.alert("Estas seguro que quieres omitir este punto?", isPresented: $showAlertOmmited, actions: { // 2
                                    
                                    // 3
                                    Button("Cancel", role: .cancel, action: {showAlertOmmited = false})
                                    Button("Ok", role: .destructive, action: {
                                        withAnimation {
                                            Rondas.isOmmited[indice][self.currentIndex] = true
                                        }
                                        
                                    })

                                }, message: {
                                    // 4
                                    Text("Antes de omitir el punto debes de agregar un comentario o foto osino habra sanciones")

                                })







                            }.frame(width: getScreenBounds().width, alignment: .leading)
                                
                                

                            if self.Rondas.haveComment[indice][i]{
                                TextField("Agrega un comentario", text: self.$Rondas.comments[indice][i])
                                    .textFieldStyle(

                                        RoundedBorderTextFieldStyle()
                                    )
                            }


                            if !self.Rondas.photoB64[indice][i].isEmpty{
                                Image(base64String: self.Rondas.photoB64[indice][i])?
                                    .resizable()
                                    .frame(width: 200, height: 200,alignment: .leading)
                                    .overlay(alignment: .topLeading){
                                        Button {
                                            self.currentIndex = i
                                            withAnimation {
                                                self.Rondas.photoB64[indice][i] = ""
                                            }
                                        } label: {
                                            Image(systemName: "trash")
                                        }

                                    }
                                Spacer()
                            }
                            
                            


                        }
                        
                        Button {
                            let namesPoint = self.Rondas.Rondas[indice].map { value in
                                value.name
                            }
                            withAnimation(.linear(duration: 1)) {
                                self.initRound = false
                                self.timer.upstream.connect().cancel()
                                dismiss()
                                let minutes = elapsedTimeInMinutes.rounded(to: 2)
                                print(minutes)
                                stopTimer()
                                let rondaTerminada = RondasFinalizadasInfo(isRealized: self.Rondas.isRealized[indice], comments: self.Rondas.comments[indice], photoB64: self.Rondas.photoB64[indice], fecha: dateToday, userRealized: userRealized, locations: self.Rondas.Locations, duracion: "\(minutes)", isOmmited: self.Rondas.isOmmited[indice], namePoint: namesPoint)
                                
                                Rondas.writeData(rondasTerminadas: rondaTerminada)
                                Rondas.finishRound(documentId: self.Rondas.arrayDocumentId[indice])
                                
                            }
                        } label: {
                            
                            Text("Finalizar ronda")
                                .padding(5)
                                .background {
                                    Color.black.opacity(0.5)
                                }
                                .cornerRadius(10)
                        }

                        
  
                    }
                    
                    
                    

                    
                }.navigationBarBackButtonHidden(true)
                .onAppear {
                    delegate.currentLocation = locationManager.location
                    locationManager.delegate = delegate
                    self.latitude = (locationManager.location?.coordinate.latitude)!
                    self.lon = (locationManager.location?.coordinate.longitude)!
                    self.region = MKCoordinateRegion(center: locationManager.location!.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)


                    let pin = Pin(coordinate: locationManager.location!.coordinate)
                    self.homeLocation.append(pin)
                    let locationss = Locations(latitude: self.latitude, longuitude: self.lon)
                    self.Rondas.Locations.append(locationss)
                    

                    
                }
                .onDisappear {
                    locationManager.stopUpdatingLocation()
                }
                .onReceive(timer) { _ in
                    guard let locationLatitude = delegate.currentLocation?.coordinate.latitude else { return }
                    guard let locationLonguitude = delegate.currentLocation?.coordinate.longitude else { return }
                    self.latitude = locationLatitude
                    self.lon = locationLonguitude

                    guard let location = delegate.currentLocation else { return }

                    let pinaregar = Pin(coordinate: location.coordinate)
                    self.homeLocation.append(pinaregar)
                    print("Location: \(self.latitude), \(self.lon)")
                    delegate.currentLocation = location
                    let locationss = Locations(latitude: self.latitude, longuitude: self.lon)
                    self.Rondas.Locations.append(locationss)
                    
                   

                    
                }
                .transition(.opacity)
            }else{
                if self.Rondas.Rondas.isEmpty{
                    Text("No rondas")
                }else{
                    ZStack{
                        VStack(spacing: 20){
                            var dateStrFirebase = "\(Rondas.Fecha), \(Rondas.Hora[indice])"
        //
                            Text("\(self.currentDate.formatted())").bold().foregroundColor(.black)
                            Text("Ronda programada para "+dateStrFirebase).bold().foregroundColor(.black)
                            
                            Button {
                                withAnimation(.linear(duration: 1)){
                                    self.initRound.toggle()
                                }
                                startTimer()

                            } label: {
                                Text("Iniciar ronda").foregroundColor(.black)
                                    .padding(5)
                                    .background {
                                        Color.blue
                                    }
                                    .cornerRadius(10)
                                
                            }.opacity(getFormattedDate(format: dateStrFirebase) <= getFormattedDate(format: self.TimeStr) ? 1 : 0.5)
                                .allowsHitTesting(getFormattedDate(format: dateStrFirebase) <= getFormattedDate(format: self.TimeStr) ? true : false)
                            
                            
                            
                        }.frame(maxHeight: .infinity, alignment: .top)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(.green, lineWidth: 3))
                            .onReceive(timerHour) { val in
                                self.TimeStr = dateFormatter.string(from: Date())
                                self.currentDate = val
                            }
                            .onAppear{
                                locationManager.delegate = delegate
                                locationManager.requestWhenInUseAuthorization()
                                locationManager.startUpdatingLocation()
                            }
                            .transition(.opacity)
                        
                    }
                }
                
            }
            
            
        }
    }
    
    private var elapsedTimeInMinutes: Double {
        return elapsedTime / 60
    }

    private func startTimer() {
        isRunning = true
        startTime = Date()
        timerTime = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(startTime!)
        }
    }

    private func stopTimer() {
        isRunning = false
        timerTime?.invalidate()
        timerTime = nil
        elapsedTime = 0.0
    }
    
    
    
    func getFormattedDate(format: String) -> Date {
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "dd/MM/yyyy, HH:mm"

        // Convert String to Date
        guard let date = dateFormatter.date(from: format) else { return Date.now}
        return date
        
    }
    
    
    @ViewBuilder
    func MostrarAlerta() -> some View{
            VStack{
                Text("Alerta")
                    .font(.title)
                    .padding()
                
                Text("\(self.alertMessage)")
                    .font(.body)
                    .padding()
                
                Button("Aceptar") {
                    withAnimation {
                        self.showAlert = false
                    }
                    
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
                .padding(.horizontal)
            }
            .frame(width: 300)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 4)
        
    }
    
}

struct RondaViewPrueba_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            RondaViewPrueba()
        }
        
    }
}


extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
