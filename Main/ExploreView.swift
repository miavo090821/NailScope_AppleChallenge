import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isEditing: Bool
    
    var body: some View {
        HStack {
            // MARK: Searching bar
            TextField("Search", text: $text, onEditingChanged: { editing in
                isEditing = editing
            })
            .padding(8)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
            .onTapGesture {
                isEditing = true
            }
            
            if isEditing {
                Button(action: {
                    // Clear the search text and end editing
                    text = ""
                    isEditing = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(8)
                }
                .padding(.trailing, 8)
            }
        }
    }
}

struct ExploreView: View {
    @Environment(\.dismiss) var dismiss
    
    let photoData: [(String, String)] = [
        ("Nails art 1",  "gel,French tip, red, caro, design, Square"),
        ("Nails art 2",  "gel,Ombre, pink, French tip, beige, Squoval,Square, Round"),
        ("Nails art 3",  "gel,Metalic, French tip, Ombre, red, pink, Almond, Oval"),
        ("Nails art 4",  "gel,Chrome, Candy Cane, pink, red, snow flake, Chrismas, Coffin, Square"),
        ("Nails art 5",  "gel,Chrome, snow flake, white, pink, French tip, Ombre, Almond, Oval"),
        ("Nails art 6",  "gel,Chrome, red, Oval, Almond"),
        ("Nails art 7",  "gel,white, design, Coffin, heart, French tip, Square"),
        ("Nails art 8",  "gel, mermaid chrome, chrome, purple, pink, Oval, Almond. "),
        ("Nails art 9",  "Gel X,charms, rose, blue, natural, Square, Coffin, French tip, marble, Ombre"),
        ("Nails art 10", "Builder gel, Milky white, Almond, natural, BIAB")
    ]
    
    @State private var searchText = ""
    @State private var isEditing = false
    @State private var savedPhotos: [String] = [] // Array to store saved photo names
    
    var filteredPhotos: [(String, String)] {
        if searchText.isEmpty {
            return photoData
        } else {
            return photoData.filter { $0.0.localizedCaseInsensitiveContains(searchText) || $0.1.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        // MARK: Back button
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 20) {
                            //MARK: Back button label
                                Text(" Explore ")
                                    .font(.custom("Inter-SemiBold", fixedSize: 29))
                                    .foregroundColor(Color("Tip Background"))
                            }
                            .frame(height: 34)
                        }
                        .frame(height: 42)
                        Spacer()
                    }
                    .frame(height: 42)
                    
                    // Search Bar
                    SearchBar(text: $searchText, isEditing: $isEditing)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(filteredPhotos.indices, id: \.self) { index in
                                VStack(spacing: 8) {
                                    // Square with photo
                                    Image("art \(index + 1)")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 150)
                                        .clipped()
                                        .cornerRadius(8)
                                    
                                    // Title and Description
                                    Text(filteredPhotos[index].0)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text(filteredPhotos[index].1) 
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                    
                                    // Rectangles with buttons
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            // Action for heart button
                                        }) {
                                            Image(systemName: "heart")
                                                .foregroundColor(.red)
                                        }
                                        .frame(width: 50)
                                        
                                        Button(action: {
                                            // Action for saved button
                                            savePhoto("art \(index + 1)") // Save the photo
                                        }) {
                                            Image(systemName: "square.and.arrow.down")
                                                .foregroundColor(.blue)
                                        }
                                        .frame(width: 50)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 16)
                                    .frame(height: 30)
                                    .background(Color.background1.opacity(0.5))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationTitle("Explore")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SavedView(savedPhotos: savedPhotos)) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
            }
        }
    }
    
    func savePhoto(_ photoName: String) {
        // Check if the photo is already saved
        if !savedPhotos.contains(photoName) {
            // If not saved, add it to the savedPhotos array
            savedPhotos.append(photoName)
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
            .preferredColorScheme(.light)
    }
}
