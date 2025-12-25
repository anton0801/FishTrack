import SwiftUI

struct NotesView: View {
    @State private var notes: [Note] = UserDefaults.standard.loadNotes()
    @State private var newNote = ""
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
                .ignoresSafeArea()
            
            VStack {
                TextField("Add Note", text: $newNote)
                    .font(.system(size: 18, design: .rounded))
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.cyan, lineWidth: 1))
                    .padding(.horizontal)
                    .shadow(color: .cyan.opacity(0.5), radius: 5)
                
                Button("Save Note") {
                    if !newNote.isEmpty {
                        notes.append(Note(text: newNote))
                        newNote = ""
                        UserDefaults.standard.saveNotes(notes)
                    }
                }
                .font(.headline)
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.blue)
                .clipShape(Capsule())
                .shadow(color: .orange.opacity(0.8), radius: 10)
                
                List {
                    ForEach(notes) { note in
                        Text(note.text)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.purple, lineWidth: 1))
                    }
                    .onDelete { indices in
                        notes.remove(atOffsets: indices)
                        UserDefaults.standard.saveNotes(notes)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Notes / Tips")
        }
    }
}

#Preview {
    NotesView()
}
