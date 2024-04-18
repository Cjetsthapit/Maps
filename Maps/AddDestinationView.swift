import SwiftUI
import CoreLocation
import MapKit
import PhotosUI

class PhotosState: ObservableObject {
    @Published var photoItem: PhotosPickerItem? {
        didSet {
            print("Photo Selected \(String(describing: photoItem))")
            photoItem?.loadTransferable(type: Image.self) { result in
                DispatchQueue.main.async {
                    switch result {
                        case .failure(let error):
                            print(error.localizedDescription)
                        case .success(let image):
                                self.image = image
                    }
                }
            }
        }
    }
    
    @Published var image: Image?
}

struct AddDestinationView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var destinations: [Destination]
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var address: String = ""
    @State private var showAlert = false
    @State private var errorMessage = ""
    @StateObject var state = PhotosState()
    @State var presentPhotos = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    FormRow(iconName: "mappin.and.ellipse", placeholder: "Location", text: $address)
                    FormRow(iconName: "text.justify", placeholder: "Description", text: $description)
                    
                }
                Group {
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .cornerRadius(10)
                    } else {
                        Button {
                            presentPhotos.toggle()
                        } label: {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(height: 300)
                                .overlay(
                                    VStack {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.white)
                                            .font(.system(size: 24))
                                        Text("Get Photo")
                                            .foregroundColor(.white)
                                            .bold()
                                    }
                                )
                        }
                        .cornerRadius(10)
                    }
                }
            }
            .photosPicker(isPresented: $presentPhotos, selection: $state.photoItem, matching: .images, preferredItemEncoding: .compatible)
            .navigationBarTitle("Add Destination", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        validateAndAddDestination()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func validateAndAddDestination() {
        guard !address.isEmpty, !description.isEmpty, state.image != nil else {
            self.errorMessage = "All fields must be filled, and a photo must be selected."
            self.showAlert = true
            return
        }
        
        geocodeAddress()
    }
    
    private func geocodeAddress() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first, let location = placemark.location else {
                self.errorMessage = "Address not found."
                self.showAlert = true
                return
            }
            
            let newDestination = Destination(
                name: self.address,
                description: self.description,
                coordinate: location.coordinate,
                images: [state.image].compactMap { $0 } // Fix here
            )
            
            if let existingIndex = destinations.firstIndex(where: { $0.name == address }) {
                // Update existing destination
                destinations[existingIndex].description = description
                destinations[existingIndex].images.append(contentsOf: [state.image].compactMap { $0 }) // Fix here
            } else {
                // Add new destination
                self.destinations.append(newDestination)
            }
            
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct FormRow: View {
    var iconName: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.vertical, 10)
    }
}
