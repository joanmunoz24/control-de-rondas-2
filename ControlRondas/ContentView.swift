//
//  ContentView.swift
//  CurrentLocation
//
//  Created by Joan Muñoz on 15-03-23.
//

import SwiftUI


struct ContentView: View{
    
    
    @State var isLogged: Bool = false
    @State var passLoged = UserDefaults.standard.string(forKey: "isLogged?")
    @State var name = UserDefaults.standard.string(forKey: "Name") ?? ""
    @State var username = UserDefaults.standard.string(forKey: "Username") ?? "BAD SOME"
    @State var isAdmin = UserDefaults.standard.string(forKey: "isAdmin") ?? "0"
    
    @State var documentId = UserDefaults.standard.string(forKey: "DocumentId") ?? ""
    @State var photoB64 = UserDefaults.standard.string(forKey: "photoB64Profile") ?? ""
    @State var phone = UserDefaults.standard.string(forKey: "Phone") ?? "No phone"
    @State var site = UserDefaults.standard.stringArray(forKey: "Site") ?? [""]
    
    var body: some View{
        return Group{
            if isLogged == true{
//                MainView(isLoged: $isLogged, name: $name, username: $username, isAdmin: $isAdmin)
                
                MainView(isLoged: self.$isLogged, name: self.$name, username: self.$username, isAdmin: self.$isAdmin, photoB64: self.$photoB64, Site: self.$site, Phone: self.$phone, DocumentId: self.$documentId)
                
                    
            }else{
                LoginView(isLogged: $isLogged, name: $name, username: $username, isAdmin: $isAdmin, photoB64: $photoB64, Site: $site, Phone: $phone, DocumentId: $documentId)
                
            }
        }.onAppear{
            print(passLoged)
            if passLoged != nil{
                
                isLogged = true
            }
        }
    }

}


//struct ContentView: View {
//
//    @ObservedObject var locationObserver = LocationObserver()
//    @State var counter = 0
//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    var homeLocation : [AnnotationItem] {
//        guard let location = locationObserver.location?.coordinate else {
//            return []
//        }
//        return [.init(name: "Home", coordinate: location)]
//    }
//
//
//
//    var body: some View {
//        VStack {
//
//
//            Map(coordinateRegion: $locationObserver.region,
//                interactionModes: .all,
//                showsUserLocation: false,
//                userTrackingMode: .constant(.follow),
//                annotationItems: homeLocation) { location in
//
//                MapAnnotation(coordinate: location.coordinate) {
//                    Circle()
//                        .strokeBorder(.red, lineWidth: 4)
//                        .frame(width: 40, height: 40)
//                }
//            }
//                .frame(height: 300)
//
//
//
//
//
//
//        }.onReceive(timer) { time in
//            if counter == 10 {
////                locationObserver.addItemInArray()
//                counter = 0
//            } else {
//                print("The time is now \(time)")
//            }
//
//            counter += 1
//        }
//    }
//
//}
//
//
//
//
//    struct ContentView_Previews: PreviewProvider {
//        static var previews: some View {
//            ContentView()
//        }
//    }
//
//
//
//    struct MapView: UIViewRepresentable {
//        var coordinate: CLLocationCoordinate2D
//
//        //Este tiene que ser el array en donde se guarden las coordenadas actulizadas
//
//        func makeUIView(context: Context) -> MKMapView {
//            MKMapView(frame: .zero)
//        }
//
//        func updateUIView(_ view: MKMapView, context: Context) {
//            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//            let region = MKCoordinateRegion(center: coordinate, span: span)
//            view.setRegion(region, animated: true)
//
//
//            //Aca es donde se debe de editar para poder agregar los datos,ya se tiene el array de los datos
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
//            view.addAnnotation(annotation)
//        }
//    }
//
//
//
//    class LocationObserver: NSObject, ObservableObject, CLLocationManagerDelegate {
//        @Published var location: CLLocation?
//        @Published var ArrayLocation: [CLLocationCoordinate2D] = []
//        @Published var region = MKCoordinateRegion(
//            center: CLLocationCoordinate2D(latitude: 38.898150, longitude: -77.034340),
//            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
//        )
//        private var hasSetRegion = false
//
//
//        private let locationManager: CLLocationManager
//
//        override init() {
//            self.locationManager = CLLocationManager()
//
//            super.init()
//
//            self.locationManager.delegate = self
//            self.locationManager.requestWhenInUseAuthorization()
//            self.locationManager.startUpdatingLocation()
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        }
//
//        func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]){
//
//            if let location = locations.last {
//                self.location = location
//
//                if !hasSetRegion {
//                    self.region = MKCoordinateRegion(center: location.coordinate,
//                                                     span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
//                    hasSetRegion = true
//                }
//            }
//
//            print(self.location?.coordinate)
//
//
//
//
//
//
//        }
//
//        func addItemInArray(_ location: CLLocationCoordinate2D){
//            self.ArrayLocation.append(location)
//        }
//
//    }
//
//
//
//
//
//
//
//struct AnnotationItem: Identifiable {
//    let id = UUID()
//    let name: String
//    let coordinate: CLLocationCoordinate2D
//}
