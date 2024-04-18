import Foundation
import SwiftUI
import MapKit

struct Destination: Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var coordinate: CLLocationCoordinate2D
    var image: Image?

}
