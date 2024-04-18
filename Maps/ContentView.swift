import SwiftUI
import MapKit
struct ContentView: View {
    @State private var selectedDestination: Destination?
    @State private var showingAddDestination = false
    
    @State private var destinations: [Destination] = []
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 44.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
    )
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: 27,
            longitude: 85
        )
    }
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, annotationItems: destinations) { destination in
                MapAnnotation(coordinate: destination.coordinate) {
                    Button(action: {
                        self.selectedDestination = destination
                    }) {
                        VStack(spacing: 0) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                                .offset(y: -10)
                        }
                    }
                }
            }

            .navigationTitle("Destinations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddDestination = true
                    }) {
                        Label("Add Destination", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDestination) {
                AddDestinationView(destinations: $destinations)
            }
            .sheet(item: $selectedDestination) { destination in
                DestinationDetail(destination: destination)
            }
        }
    }
}

struct DestinationDetail: View {
    @Environment(\.presentationMode) var presentationMode
    var destination: Destination
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if let image = destination.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    Text(destination.description)
                        .padding()
                }
                .navigationTitle(destination.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Label("Dismiss", systemImage: "arrow.down")
                                .labelStyle(.titleAndIcon)
                        }
                    }
                }
            }
        }
    }
}

