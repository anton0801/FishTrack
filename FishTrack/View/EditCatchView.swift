import SwiftUI
import WebKit


struct FishContentHostView: UIViewRepresentable {
    let contentURL: URL
    
    @StateObject private var contentManager = FishContentManager()
    
    func makeCoordinator() -> FishNavigationCoordinator {
        FishNavigationCoordinator(manager: contentManager)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        contentManager.initializePrimaryView()
        contentManager.primaryView.uiDelegate = context.coordinator
        contentManager.primaryView.navigationDelegate = context.coordinator
        
        contentManager.loadStoredCookies()
        contentManager.primaryView.load(URLRequest(url: contentURL))
        
        return contentManager.primaryView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}


struct EditCatchView: View {
    let catchItem: Catch
    @Binding var catches: [Catch]
    @Environment(\.dismiss) var dismiss
    
    @State private var date: Date
    @State private var fishType: String
    @State private var weight: String
    @State private var length: String
    @State private var location: String
    @State private var notes: String
    
    init(catchItem: Catch, catches: Binding<[Catch]>) {
        self.catchItem = catchItem
        self._catches = catches
        self._date = State(initialValue: catchItem.date)
        self._fishType = State(initialValue: catchItem.fishType)
        self._weight = State(initialValue: String(catchItem.weight))
        self._length = State(initialValue: catchItem.length != nil ? String(catchItem.length!) : "")
        self._location = State(initialValue: catchItem.location)
        self._notes = State(initialValue: catchItem.notes)
    }
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
                .ignoresSafeArea()
            
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.black.opacity(0.5))
                TextField("Fish Type", text: $fishType)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.black.opacity(0.5))
                TextField("Weight (kg)", text: $weight)
                    .keyboardType(.decimalPad)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.black.opacity(0.5))
                TextField("Length (cm, optional)", text: $length)
                    .keyboardType(.decimalPad)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.black.opacity(0.5))
                TextField("Location", text: $location)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.black.opacity(0.5))
                TextField("Notes", text: $notes)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.black.opacity(0.5))
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Edit Catch")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let weightDouble = Double(weight), !fishType.isEmpty {
                            let lengthDouble = Double(length)
                            if let index = catches.firstIndex(where: { $0.id == catchItem.id }) {
                                catches[index] = Catch(id: catchItem.id, date: date, fishType: fishType, weight: weightDouble, length: lengthDouble, location: location, notes: notes)
                            }
                            dismiss()
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .leading, endPoint: .trailing))
                }
            }
        }
    }
}
