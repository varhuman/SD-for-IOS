import SwiftUI

struct AlertView: View {
    @Binding var isPresented: Bool
    let title: String
    let message: String

    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    Text(title)
                        .font(.headline)
                        .padding(.top)
                    Text(message)
                        .padding(.horizontal)
                        .padding(.bottom)
                    Button("OK") {
                        isPresented = false
                    }
                    .padding(.bottom)
                }
                .frame(width: 300)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 10)
            }
            .padding(.top, geometry.safeAreaInsets.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}
