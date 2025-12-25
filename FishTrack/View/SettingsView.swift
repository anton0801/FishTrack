import SwiftUI

struct SettingsView: View {
    @Binding var catches: [Catch]
    @State private var units = UserDefaults.standard.loadSettings()
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
                .ignoresSafeArea()
            
            Form {
                Picker("Units", selection: $units) {
                    Text("kg").tag("kg")
                    Text("lb").tag("lb")
                }
                .pickerStyle(SegmentedPickerStyle())
                .listRowBackground(Color.black.opacity(0.5))
                
                Button("Reset Data") {
                    catches = []
                    UserDefaults.standard.saveCatches([])
                }
                .foregroundColor(.red)
                .listRowBackground(Color.black.opacity(0.5))
                
                Button {
                    UIApplication.shared.open(URL(string: "https://fishtraack.com/privacy-policy.html")!)
                } label: {
                    Text("Privacy Policy")
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .onChange(of: units) { newUnits in
                UserDefaults.standard.saveSettings(units: newUnits)
            }
        }
    }
}

