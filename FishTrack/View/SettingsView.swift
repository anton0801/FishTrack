import SwiftUI

struct SettingsView: View {
    @Binding var catches: [Catch]
    @State private var units = UserDefaults.standard.loadSettings()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6), Color.green.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            Form {
                Picker("Units", selection: $units) {
                    Text("kg").tag("kg")
                    Text("lb").tag("lb")
                }
                Button("Reset Data") {
                    catches = []
                    UserDefaults.standard.saveCatches([])
                }
                .foregroundColor(.red)
//                NavigationLink("Privacy / About") {
//                    Text("About Fish Track App")
//                        .foregroundColor(.white)
//                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .onChange(of: units) { newUnits in
                UserDefaults.standard.saveSettings(units: newUnits)
            }
        }
    }
}

