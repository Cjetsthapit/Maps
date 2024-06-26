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
                if let index = destinations.firstIndex(where: { $0.id == destination.id }) {
                    DestinationDetail(destination: $destinations[index])
                }
            }

        }
    }
}

struct DestinationDetail: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var destination: Destination
    @State private var showAlert = false
    @State private var deleteIndex: Int?

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(destination.description)
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .padding()
                    
                    Text("Travel Photos")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    if destination.images.isEmpty {
                        Text("No Photos")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(destination.images.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                destination.images[index]
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(10)
                                    .padding()
                                
                                    
                                if destination.images.count > 1 {
                                    Button(action: {
                                        self.showAlert = true
                                        self.deleteIndex = index
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .padding(10)
                                            .background(Color.white.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(.trailing, 10)
                                    .padding(.top, 10)
                                }
                            }
                        }
                    }
                    
                  
                }
                .navigationBarTitle(destination.name)
                .navigationBarItems(leading: Button("Dismiss") {
                    presentationMode.wrappedValue.dismiss()
                })

               
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Delete Image"), message: Text("Are you sure you want to delete this image?"), primaryButton: .destructive(Text("Delete")) {
                    if let deleteIndex = deleteIndex {
                        destination.images.remove(at: deleteIndex)
                    }
                }, secondaryButton: .cancel())
            }
        }
    }
}
