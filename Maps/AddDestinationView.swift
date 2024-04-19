import SwiftUI
import CoreLocation
import MapKit
import PhotosUI

class PhotosState: ObservableObject {
    @Published var photoItem: PhotosPickerItem? {
        didSet {
            print("Photo Selected \(photoItem.debugDescription)")
            photoItem?.loadTransferable(type: Image.self) { result in
                DispatchQueue.main.async {
                    switch result {
                        case .failure(let error):
                            print(error.localizedDescription)
                        case .success(let image):
                            if let image = image {
                                self.images.append(image)
                            }
                    }
                }
            }
            print(images.last ?? "No images")
        }
    }
    
    @Published var images: [Image] = []
   
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
                    Button(action: {
                        presentPhotos = true
                    }) {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 100)
                            .overlay(
                                VStack {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.white)
                                        .font(.system(size: 24))
                                    Text("Add Photo")
                                        .foregroundColor(.white)
                                        .bold()
                                }
                            )
                            .cornerRadius(10)
                    }
                    ForEach(state.images.indices, id: \.self) { index in
                        state.images[index]
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
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
        guard !address.isEmpty, !description.isEmpty, !state.images.isEmpty else {
            errorMessage = "All fields must be filled, and at least one photo must be selected."
            showAlert = true
            return
        }
        
        geocodeAddress()
    }
    
    private func geocodeAddress() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first, let location = placemark.location else {
                errorMessage = "Address not found."
                showAlert = true
                return
            }
            
            let newDestination = Destination(
                name: self.address,
                description: self.description,
                coordinate: location.coordinate,
                images: self.state.images
            )
            
            destinations.append(newDestination)
            presentationMode.wrappedValue.dismiss()
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
