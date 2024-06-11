import SwiftUI

struct WhatsthetrendView: View {
    
    // MARK: Description content + photo list
    //Many people do not know what the new, advanced, trendy technique for their nails care service
    let data: [(String, String, [String])] = [
        ("Builder Gel (BIAB)", "Builder gel is a range of strengthening gel products that are applied to the natural nail, much in the same way regular gel polishes are, but it has a thicker consistency that improves the nail's strength.", ["art 1"]),
        ("Dipping Powder", "Individuals with oily nail beds or chip-prone nails, for example, may have trouble getting a gel manicure to last for more than two weeks. If that describes you, dip powder nails are the superior option because they're built up in layers, which enhances nail strength and creates a barrier against chipping.", ["art 2"]),
        ("Gel Manicure", "Gel nails refer to a type of nail polish that is cured with a UV nail lamp to create a shiny, long-lasting manicure that doesn’t require extensive time to dry. Gel nail polish usually follows a three-step process, which consists of a base coat, gel nail polish and finally, top coat.", ["art 3"]),
        ("Regular Polish", "Your average nail polish, also known as traditional polish, is made with color pigments dissolved in a solvent. As the solvent evaporates, it leaves behind a coating of color on your nails. The application is straightforward: shape your nails, apply a base coat, then the polish color, and finally a top coat.", ["art 4"]),
        ("Acrylic", "Acrylic nails are made by mixing a liquid (monomer) and powder (polymer) to create a paste, which is then applied to the natural nails. The mixture hardens and forms a durable layer over the natural nails. Acrylic nails are known for their durability and strength, and they can be shaped and filed to create various looks.", ["art 5"]),
        ("Gel X", "Gel-X is a soft, extension meaning it artificially lengthens your nails but still feels flexible, not hard, plastic-y, and molded from, as the name says, gel. This is an iteration of the same material that you would get during a typical gel appointment, made from a blend of acrylic monomers and oligomers", ["art 6"]),
        ("Hard Gel", "Technically speaking, hard gel (also called traditional or standard gel) is similar to acrylic in its chemical makeup. It’s made of monomers and/or oligomers (chains of monomers) plus other ingredients that help the gel remain workable, adhere to the nail, harden properly and resist yellowing. Hard gel is applied to the nail straight from the pot (no mix ratio required) and each layer is cured under a UV or LED light.", ["art 7"]),
        ("ManiCure & Pedicure", "Manicures and pedicures are both treatments for your hands and feet, but the difference between them is more than just a matter of size. A manicure involves trimming, shaping, and buffing fingernails; a pedicure typically involves exfoliating the skin on your feet before soaking them in warm water.", ["art 8"]),
        ("Russian Manicure", "Russian Manicure: What Is It, and Is It Actually Bad for Your ... The Russian manicure technique removes as much skin as possible from the nail area, which leaves more room for polish. This results in a “cleaner”-looking finish and helps to extend the length of time between appointments, as the skin and nail take longer to grow back than with regular manicures.", ["art 9"])
    ]

    var body: some View {
        VStack(spacing: 20) {
            // Drag Indicator
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.3))
                .frame(width: 40, height: 6)
                .padding(.top, 10)

            // Content
            VStack {
                Text("What's the trend now?")
                    .font(.title)
                    .padding()
                    .foregroundColor(Color("Tip Background"))
                    

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        ForEach(data.indices) { index in
                            TrendItemView(title: data[index].0, description: data[index].1, imageNames: data[index].2)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.WhatsTheTrendNow)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
        )
        .shadow(radius: 5)
    }
}

struct WhatsthetrendView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsthetrendView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

struct TrendItemView: View {
    @State private var isExpanded = false
    let title: String
    let description: String
    let imageNames: [String]

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.purple)
                Spacer()
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.purple)
                }
            }
            .padding(.horizontal)

            if isExpanded {
                Text(description)
                    .foregroundColor(.black)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(imageNames, id: \.self) { imageName in
                            SquarePhotoView(imageName: imageName)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
    }
}

struct SquarePhotoView: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 80, height: 80)
            .cornerRadius(10)
    }
}
