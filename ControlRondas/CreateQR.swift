//
//  CreateQR.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 30-07-23.
//

import SwiftUI
import Combine
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreLocation
import Combine
import MapKit

struct CreateQR: View {
    
    @State private var caracteres = ""
    @State private var namepoint = ""
    @State var qr = ""
    @State var latitude = ""
    @State var lon = ""
    @State private var delegate = LocationDelegate()
    @State private var locationManager = CLLocationManager()
    @State var loading = false
    @StateObject var modeloQR = ModelQR()
    @State var nameClient = "Nombre Cliente"
    @State var nameSite = "Nombre Site"
    
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    init(){
    }
    
    var body: some View {
        
        
        
        ZStack{
            if loading{
                ProgressView("Creando qr..")
            }else{
                VStack{
                    
                    VStack(spacing: 0){
                        TextField("Ingresa el nombre del Cliente", text: $nameClient).frame(height: 50, alignment: .center)
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color.black)
                        
                        TextField("Ingresa el nombre del site del cliente", text: $nameSite).frame(height: 50, alignment: .center)
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color.black)
                        
                        
                        TextField("Ingresa el nombre del punto", text: $namepoint).frame(height: 50, alignment: .center)
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color.black)
                    }
                    
                    Text("\(namepoint)\(caracteres)")
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    
                    
                    Spacer()
                    
                    Image(uiImage: createQRCode(from: "\(namepoint)\(caracteres)"))
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                    
                    
                    Spacer()
                    Button {
                        let image = createQRCode(from: "\(namepoint)\(caracteres)")
                        let b64 = imageToBase64(image: image)
                        let dataSend = modelQR(b64QR: b64, Name: self.namepoint,Site: self.nameSite.uppercased(), Cliente: self.nameClient.uppercased(), latitude: self.latitude, longuitude: self.lon)
                        modeloQR.writeData(dataSend, self.nameSite.uppercased(),self.nameClient.uppercased())
                        loading = true
                        self.namepoint = ""
                        self.caracteres = ""
                        self.Loading()
                        print(b64)
                    } label: {
                        Text("Save QR")
                            .padding()
                            .background(
                                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                                    .stroke(.cyan, lineWidth: 3)
                            )
                    }
                }
                .padding(.horizontal)
                .onAppear{
                    delegate.currentLocation = locationManager.location
                    locationManager.delegate = delegate
                    locationManager.requestWhenInUseAuthorization()
                    
                    let latitude = locationManager.location?.coordinate.latitude
                    let lon = locationManager.location?.coordinate.longitude
                    
                    self.latitude = String(format: "%.6f", latitude!)
                    self.lon = String(format: "%.6f", lon!)
                    print(latitude)
                    print(lon)
                    //            locationManager.requestLocation()
                    
                    caracteres = caracteres + "," + self.latitude + "," + self.lon
                }
            }
            

            
        }
    }

    
    func createQRCode(from string:String) -> UIImage{
        filter.message = Data(string.utf8)
        
        if let outoutImage = filter.outputImage{
            if let cgimg  = context.createCGImage(outoutImage, from: outoutImage.extent){
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func saveQRCodeToGallery(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func imageToBase64(image: UIImage) -> String{
        let data = image.pngData()
        let b64 = data?.base64EncodedString() ?? ""
        return b64
    }
    
    func Loading(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loading = false
        }
    }
}

struct CreateQR_Previews: PreviewProvider {
    static var previews: some View {
        CreateQR()
    }
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var latitude: String = ""
    @Published var longitude: String = ""
    
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        self.latitude = String(format: "%.6f", latitude)
        self.longitude = String(format: "%.6f", longitude)
    }
}
