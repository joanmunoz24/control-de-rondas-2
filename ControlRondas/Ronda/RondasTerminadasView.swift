//
//  RondasTerminadasView.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 05-08-23.
//

import SwiftUI
import MapKit
import _MapKit_SwiftUI

struct RondasTerminadasView: View {
    @ObservedObject var RondaFinalizadasModel = RondasTerminadas()
    @AppStorage("Name") var nombre = ""
    var isAdmin: Bool
    var body: some View {
        
        if RondaFinalizadasModel.ArrayRondasFinalizadas.isEmpty{
            ProgressView("LoadingData").onAppear{
                if isAdmin{
                    self.RondaFinalizadasModel.fetchData()
                }else{
                    self.RondaFinalizadasModel.fetchDataByVigilant(nombre)
                }
                
            }
        }else{
            List{
                ForEach(self.RondaFinalizadasModel.ArrayRondasFinalizadas.indices, id:\.self){ value in
                    let user = self.RondaFinalizadasModel.ArrayRondasFinalizadas[value].userRealized
                    let fecha = self.RondaFinalizadasModel.ArrayRondasFinalizadas[value].fecha
                    let duracion = self.RondaFinalizadasModel.ArrayRondasFinalizadas[value].duracion
                    let namePoint = self.RondaFinalizadasModel.ArrayRondasFinalizadas[value].namePoint
                    let photoB64 = self.RondaFinalizadasModel.ArrayRondasFinalizadas[value].photoB64
                    let comment = self.RondaFinalizadasModel.ArrayRondasFinalizadas[value].comments

                    
                    NavigationLink {
                        //Vista para mostrar la ruta.
                        showRoute(locations: self.RondaFinalizadasModel.ArrayRondasFinalizadas[value].locations, puntosRealizados: self.RondaFinalizadasModel.ArrayRondasFinalizadas[value].isRealized,namePoint: namePoint,photoB64: photoB64,comment: comment)
                    } label: {
                        HStack{
                            Image(systemName: "person.circle")
                                .font(.system(size: 30))
                            VStack(alignment: .leading){
                                Text(user).bold()
                                Text("\(fecha) \(duracion) min")
                            }
                            
                            
                        }
                    }

                    

                }
            }
        }
        
    }
}


struct showRoute: View{
    var locations: [Locations]
    var puntosRealizados: [Bool]
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    @State var arrayPuntosRealizados:[Bool] = []
    
    var namePoint:[String]
    var photoB64: [String]
    var comment: [String]
    
    var body: some View{
        ZStack(alignment:.top){
            VStack{
                Text("Puntos realizados \(arrayPuntosRealizados.count)/\(puntosRealizados.count)").bold()

                NavigationLink {
                    showMoreDetailRondas(namePoint: namePoint, photoB64: photoB64, comment: comment)
                } label: {
                    Text("ver mas")
                }


                Spacer()
                
                MapView(coordinates: locations)
                    .frame(height: getScreenBounds().height/1.5)
//                Map(coordinateRegion:$region ,
//                                interactionModes: .all,
//                                showsUserLocation: false,
//                                userTrackingMode: .constant(.none),
//                                annotationItems: locations) { location in
//
//                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longuitude)) {
//                                    Circle().fill(Color.red).frame(width: 20, height: 20)
//
//                                }
//                            }
//                                .frame(height: getScreenBounds().height/3)
                
                
            }.tint(.black)

        }
        .onAppear {
            let latitude = locations.first?.latitude
            let longuitude = locations.first?.longuitude
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude!, longitude: longuitude!), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
            puntosRealizados.forEach { val in
                if val == true{
                    arrayPuntosRealizados.append(val)
                }
            }
        }

    }
}


//aca deben de aparecer las imagenes y los comentarios de los puntos realizados.
struct showMoreDetailRondas:View{
    var namePoint:[String]
    var photoB64: [String]
    var comment: [String]
    
    var body: some View{
        List{
            ForEach(namePoint.indices, id:\.self) { val in
                Section {
                    HStack{
                        if !photoB64[val].isEmpty{
                            Image(base64String: photoB64[val])?
                                .resizable()
                                .background(Color.red)
                                .frame(width: 200, height: 200,alignment: .leading)
                                
                        }else{
                            Text("No image")
                        }
                        
                        if !comment[val].isEmpty{
                            Text(comment[val])
                                .bold()
                                
                                
                        }
                        

                    }
                } header: {
                    Text(self.namePoint[val])
                }

            }
        }
    }
}

struct RondasTerminadasView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            RondasTerminadasView(isAdmin: true)
        }
        
    }
}



struct MapView: UIViewRepresentable {
    let coordinates: [Locations]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Remueve las anotaciones anteriores
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)

        
        let coordinates = self.coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longuitude) }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        uiView.addOverlay(polyline)
        
        if let firstCoordinate = coordinates.first {
//
            
            let startAnnotation = MKPointAnnotation()
            startAnnotation.coordinate = firstCoordinate

            startAnnotation.title = "Inicio"
            uiView.addAnnotation(startAnnotation)
        

        }
        
        // Agregar anotación para el fin
        if let lastCoordinate = coordinates.last {
            let endAnnotation = MKPointAnnotation()
            endAnnotation.coordinate = lastCoordinate
            endAnnotation.title = "Fin"
            uiView.addAnnotation(endAnnotation)
        }
        // Establece la región del mapa
        if let firstCoordinate = coordinates.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: firstCoordinate.latitude, longitude: firstCoordinate.longitude), span: span)
            uiView.setRegion(region, animated: true)
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                //sera de color azul, ya que siempre los caminos son de color azul.
                renderer.strokeColor = .blue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        
        //puede ser que por el tema de la funcionn de arriba que no este funcionando de buena maneera.
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if annotation.title == "Fin" {
//                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "endAnnotation")
//                annotationView.pinTintColor = .blue
//                annotationView.canShowCallout = true
//                annotationView.tintColor = .black
//                return annotationView
//            }
//            return nil
//        }

    }

}


extension MKCoordinateRegion {
    init(coordinates: [CLLocationCoordinate2D]) {
        let minLat = coordinates.min { $0.latitude < $1.latitude }?.latitude ?? 0
        let maxLat = coordinates.max { $0.latitude < $1.latitude }?.latitude ?? 0
        let minLon = coordinates.min { $0.longitude < $1.longitude }?.longitude ?? 0
        let maxLon = coordinates.max { $0.longitude < $1.longitude }?.longitude ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.2,
            longitudeDelta: (maxLon - minLon) * 1.2
        )
        
        self.init(center: center, span: span)
    }
}

