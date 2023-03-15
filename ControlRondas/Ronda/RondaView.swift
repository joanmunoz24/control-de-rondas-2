//
//  RondaView.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 06-05-23.
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



class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var currentLocation: CLLocation?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }
}

struct RondaView: View {
    
    
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
    
    @State var showScanner = false
    @State var showAlert:Bool = false
    @State var alertMessage = ""
    @State var messageOfQR = ""
    @State var nameOfQR = ""
    
    @State var latFirebase = 0.0
    @State var lonFirebase = 0.0
    @State var nameFirebase = ""
    @State var currentIndex = 0
    
    @State private var isShowingImagePicker = false

    
    
    @StateObject var Firebase = ViewModel()

    
    init(){
        _region = State(initialValue: MKCoordinateRegion(center: locations.coordinate, latitudinalMeters: 500, longitudinalMeters: 500))
    }
    
    
    
    var body: some View {
        
        //ACA ES CUANDO SI INICIA LA REALIZACION DE LA RONDA
        if initRound{
            ZStack(alignment: .top) {
                
                VStack(spacing: 10){
                    Text("Latitud: \(latitude), Longitud: \(lon)").foregroundColor(.black)
                    
//                    Map(coordinateRegion:$region ,
//                                    interactionModes: .all,
//                                    showsUserLocation: false,
//                                    userTrackingMode: .constant(.follow),
//                                    annotationItems: homeLocation) { location in
//
//                                    MapAnnotation(coordinate: location.coordinate) {
//                                        Circle().fill(Color.blue).frame(width: 10, height: 10)
//
//                                    }
//                                }
//                                    .frame(height: 300)
                    
                    
                    
                    if showAlert == true{
                            MostrarAlerta().zIndex(2)
                        }
                
                
                    ForEach(Firebase.Rondas.indices) { i in
                        var name = "\(Firebase.Rondas[i].name)"
                        var latitude = Double("\(Firebase.Rondas[i].latitude)")
                        var longuitude = Double("\(Firebase.Rondas[i].longuitude)")
                        let valordei = Int(i)


                        HStack(spacing: 0){

                            if Firebase.isOmmited[i] == true{
                                Text("OM")
                                    .foregroundColor(.red)
                                    .bold()
                                    .frame(width: getScreenBounds().width*0.1)
                            }else{

                                Text(Firebase.isRealized[i] ? "Ok" : "PDT")
                                    .foregroundColor(Firebase.isRealized[i] ? .green : .black)
                                    .bold()
                                    .frame(width: getScreenBounds().width*0.1)
                            }



                            Button {
                                
                                //se deben de crear las variables de esta manera, ya q al entrar en otro contexto en el lector de qr, solamente toma los valores del primer indice
                                
                                self.nameFirebase = name
                                self.lonFirebase = longuitude!
                                self.latFirebase = latitude!
                                self.showScanner = true
                                self.currentIndex = i

                            } label: {
                                Text(name)
                                    .foregroundColor(.black)
                                    .frame(width: getScreenBounds().width*0.6)
                                    .background {
                                        Color.red
                                    }
                                    .cornerRadius(10)

                            }

                            .sheet(isPresented: $showScanner) {
                                CodeScannerView(codeTypes: [.qr], completion: { result in
                                    if case let .success(code) = result{
                                        let arrayMessage = code.string.split(separator: ",")
                                        self.nameOfQR = String(arrayMessage[0])
                                        self.latitude = Double(arrayMessage[1])!
                                        self.lon = Double(arrayMessage[2])!
                                        let margin: Double = 0.000009   // Aproximadamente 1 metro en términos de latitud y longitud
                                        let valorsaber = valordei
                                        


                                        if (self.latFirebase - 0.150 <= self.latitude && self.latFirebase + 0.150 >= self.latitude) &&
                                            (self.lonFirebase - 0.150 <= self.lon && self.lonFirebase + 0.150 >= self.lon && self.nameOfQR == self.nameFirebase){


                                            Firebase.isRealized[self.currentIndex] = true
                                            print("son los mismo puntos")

                                            self.showScanner = false
                                            self.showAlert = true
                                            self.alertMessage = "Se ha realizado con exito el punto"
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
                                    Firebase.haveComment[i] = true
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
                                print("has presionda el valor de agregar imagen en \(name)")
                                withAnimation {
                                    self.currentIndex = i
                                    self.isShowingImagePicker.toggle()
                                }

                            } label: {
                                Image(systemName: "camera")
                                    .foregroundColor(.black)
                                    .frame(width: getScreenBounds().width*0.1)
                                    .background {
                                        Color.white
                                    }
                                    .cornerRadius(10)
                            }.sheet(isPresented: $isShowingImagePicker) {
                                ImagePickerView(selectedImage: self.$Firebase.photoB64[currentIndex], sourceType: .constant(.camera))
                                

                            }



                            Button {
                                withAnimation {
                                    Firebase.isOmmited[i] = true
                                }

                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                                    .frame(width: getScreenBounds().width*0.1)
                                    .background {
                                        Color.white
                                    }
                                    .cornerRadius(10)

                            }







                        }.frame(width: getScreenBounds().width, alignment: .leading)

                        if Firebase.haveComment[i]{
                            TextField("Agrega un comentario", text: $Firebase.comments[i])
                                .textFieldStyle(

                                    RoundedBorderTextFieldStyle()
                                )
                        }
                        
                        
                        if !Firebase.photoB64[i].isEmpty{
                            Image(base64String: Firebase.photoB64[i])?
                                .resizable()
                                .background(Color.red)
                                .frame(width: 200, height: 200,alignment: .leading)
                                .overlay(alignment: .topLeading){
                                    Button {
                                        self.currentIndex = i
                                        withAnimation {
                                            self.Firebase.photoB64[currentIndex] = ""
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                    }

                                }
                        }
                        
                        


                    }
                    
                    Button {
                        withAnimation(.linear(duration: 1)) {
                            self.initRound = false
                            self.timer.upstream.connect().cancel()
                        }
                    } label: {
                        Text("stop")
                            .padding(5)
                            .background {
                                Color.black.opacity(0.5)
                            }
                            .cornerRadius(10)
                    }

                    
                    Button{
                        let namesPoint = self.Firebase.Rondas.map { value in
                            value.name
                        }
                        
                        let rondaTerminada = RondasFinalizadasInfo(isRealized: Firebase.isRealized, comments: Firebase.comments, photoB64: Firebase.photoB64, fecha: dateToday, userRealized: userRealized, locations: Firebase.Locations, duracion: "6'", isOmmited: Firebase.isOmmited,namePoint: namesPoint)
                        Firebase.writeData(rondasTerminadas: rondaTerminada)
                        self.timer.upstream.connect().cancel()
                        self.initRound = false

                    } label: {
                        Text("Terminar ronda")
                            .padding(5)
                            .background {
                                Color.black.opacity(0.5)
                                
                            }
                            .cornerRadius(10)
                    }
                }
                
                
                

                
            }
            .onAppear {
                delegate.currentLocation = locationManager.location
                locationManager.delegate = delegate
                self.latitude = (locationManager.location?.coordinate.latitude)!
                self.lon = (locationManager.location?.coordinate.longitude)!
                self.region = MKCoordinateRegion(center: locationManager.location!.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)

                
                let pin = Pin(coordinate: locationManager.location!.coordinate)
                self.homeLocation.append(pin)
                let locationss = Locations(latitude: self.latitude, longuitude: self.lon)
                self.Firebase.Locations.append(locationss)
//                let locationsJSON: [String: Any] = [
//                    "latitude": self.latitude,
//                    "longitude": self.lon
//                ]
//                let jsonData = try! JSONSerialization.data(withJSONObject: locationsJSON)
//                let jsonString = String(data: jsonData, encoding: .utf8)
//                self.Firebase.Location.append(jsonString!)
                

                
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
                self.Firebase.Locations.append(locationss)
                
               

                
            }
            .transition(.opacity)
        }//TERMINO DEL IF, DONDE SE REALIZA LA RONDA.
        
        else{
  
            if Firebase.Rondas.isEmpty{
                ProgressView("Obteniendo los datos").onAppear{
                    Firebase.getData()
                }
            }else{
                ZStack{
                    

                    
                    VStack(spacing: 20){
                        var dateStrFirebase = "\(Firebase.Data[0]), \(Firebase.Data[1])"
                        
                        Text("\(self.currentDate.formatted())").bold().foregroundColor(.white)
                        Text("Ronda programada para "+dateStrFirebase).bold().foregroundColor(.white)
                        
                        
//                        VStack(spacing: 20){
//                            ForEach(Firebase.Rondas.indices) { i in
//                                let name = Firebase.Rondas[i].name.uppercased()
//                                let latitude = Double(Firebase.Rondas[i].latitude)
//                                let longuitude = Double(Firebase.Rondas[i].longuitude)
//
//
//                                HStack(spacing: 0){
//
//                                    if Firebase.isOmmited[i] == true{
//
//                                        Text("OM")
//                                            .foregroundColor(.red)
//                                            .bold()
//                                            .frame(width: getScreenBounds().width*0.1)
//                                    }else{
//
//                                        Text(Firebase.isRealized[i] ? "Ok" : "PDT")
//                                            .foregroundColor(Firebase.isRealized[i] ? .green : .black)
//                                            .bold()
//                                            .frame(width: getScreenBounds().width*0.1)
//                                    }
//
//
//
//                                    Button {
//
//                                        self.showScanner = true
//
//                                    } label: {
//                                        Text(name)
//                                            .foregroundColor(.black)
//                                            .frame(width: getScreenBounds().width*0.6)
//                                            .background {
//                                                Color.red
//                                            }
//                                            .cornerRadius(10)
//
//                                    }
//
//                                    .sheet(isPresented: $showScanner) {
//                                        CodeScannerView(codeTypes: [.qr], completion: { result in
//                                            if case let .success(code) = result{
//                                                let arrayMessage = code.string.split(separator: ",")
//                                                print(arrayMessage[2])
//                                                self.nameOfQR = String(arrayMessage[0])
//                                                self.latitude = Double(arrayMessage[1])!
//                                                self.lon = Double(arrayMessage[2])!
//                                                print("name \(nameOfQR) latitude: \(self.latitude) longuitude:v \(self.lon)")
//                                                print("lat: \(latitude) lon: \(longuitude)")
//
//
//                                                if (latitude! - 0.150 <= self.latitude && latitude! + 0.150 >= self.latitude) &&
//                                                    (longuitude! - 0.150 <= self.lon && longuitude! + 0.150 >= self.lon && self.nameOfQR == name){
//                                                    Firebase.isRealized[i] = true
//                                                    print("son los mismo puntos")
//
//                                                    self.showScanner = false
//                                                    self.showAlert = true
//                                                    self.alertMessage = "Se ha realizado con exito el punto"
//                                                }else{
//
//                                                    self.showScanner = false
//                                                    self.showAlert = true
//                                                    print("No son los mismos puntos")
//                                                    self.alertMessage = "No se puedo realizar el punto"
//                                                }
//
//
//
//
//                                            }
//
//                                        }
//                                        )
//                                    }
//
//
//
//
//                                    Button {
//                                        withAnimation {
//                                            Firebase.haveComment[i] = true
//                                        }
//                                    } label: {
//                                        Image(systemName: "text.bubble")
//                                            .foregroundColor(.black)
//                                            .frame(width: getScreenBounds().width*0.1)
//                                            .background {
//                                                Color.white
//                                            }
//                                            .cornerRadius(10)
//                                    }
//
//
//
//
//
//                                    Button {
//                                        print("has presionda el valor de agregar imagen en \(name)")
//                                    } label: {
//                                        Image(systemName: "camera")
//                                            .foregroundColor(.black)
//                                            .frame(width: getScreenBounds().width*0.1)
//                                            .background {
//                                                Color.white
//                                            }
//                                            .cornerRadius(10)
//                                    }
//
//
//                                    Button {
//                                        withAnimation {
//                                            Firebase.isOmmited[i] = true
//                                        }
//
//                                    } label: {
//                                        Image(systemName: "xmark")
//                                            .foregroundColor(.black)
//                                            .frame(width: getScreenBounds().width*0.1)
//                                            .background {
//                                                Color.white
//                                            }
//                                            .cornerRadius(10)
//
//                                    }
//
//
//
//
//
//
//
//                                }.frame(width: getScreenBounds().width, alignment: .leading)
//
//                                if Firebase.haveComment[i]{
//                                    TextField("Agrega un comentario", text: $Firebase.comments[i])
//                                        .textFieldStyle(
//
//                                            RoundedBorderTextFieldStyle()
//                                        )
//                                }
//
//
//                            }
//                        }
//                        .alert(alertMessage, isPresented: $showAlert) {
//                            Button("OK") { }
//                        } message: {
//                            Text("This is a small message below the title, just so you know.")
//                        }
                        
                        Button {
                            withAnimation(.linear(duration: 1)){
                                self.initRound.toggle()
                            }
    
                        } label: {
                            Text("Iniciar Ronda a las  \(Firebase.Data[1] as! String)").foregroundColor(.black)
                                .padding(5)
                                .background {
                                    Color.white
                                }
                                .cornerRadius(10)
                        }.opacity(getFormattedDate(format: dateStrFirebase) <= getFormattedDate(format: self.TimeStr) ? 1 : 0.5)
                            .allowsHitTesting(getFormattedDate(format: dateStrFirebase) <= getFormattedDate(format: self.TimeStr) ? true : false)
                        
                        
                        
                    }.frame(maxHeight: .infinity, alignment: .top)
                        .onReceive(timerHour) { val in
                            self.TimeStr = dateFormatter.string(from: Date())
                            self.currentDate = val
                        }
                        .onAppear{
                            locationManager.delegate = delegate
                            locationManager.requestWhenInUseAuthorization()
                            locationManager.startUpdatingLocation()
                        }
                        .background {
                            Image("prueba1")
                        }
                        .transition(.opacity)
                    
                }
                
                

            }

            
            


        }
        

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


struct RondaView_Previews: PreviewProvider {
    static var previews: some View {
        RondaView()
    }
}


extension Date {
    func relativeTime(in locale: Locale = .current) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageBase64: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                if let imageData = image.pngData() {
                    parent.imageBase64 = imageData.base64EncodedString()
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    @Binding var image: Image?
    var captureSession: AVCaptureSession
    
    init(image: Binding<Image?>, captureSession: AVCaptureSession) {
        _image = image
        self.captureSession = captureSession
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let uiImage = UIImage(data: imageData) {
            let b64 = imageData.base64EncodedString()
            image = Image(uiImage: uiImage)
        }
        
        captureSession.stopRunning()
    }
}




class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView

    init(picker: ImagePickerView) {
        self.picker = picker
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        let b64 = selectedImage.jpegData(compressionQuality: 0.3)?.base64EncodedString()
        self.picker.selectedImage = b64 ?? ""
        self.picker.isPresented.wrappedValue.dismiss()
    }

}




struct ImagePickerView: UIViewControllerRepresentable {

    @Binding var selectedImage: String
    @Environment(\.presentationMode) var isPresented
    @Binding var sourceType: UIImagePickerController.SourceType


    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator // confirming the delegate
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

    // Connecting the Coordinator class with this struct
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

