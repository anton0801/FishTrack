import SwiftUI

struct NotesView: View {
    @State private var notes: [Note] = UserDefaults.standard.loadNotes()
    @State private var newNote = ""
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6), Color.green.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                TextField("Add Note", text: $newNote)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button("Save Note") {
                    if !newNote.isEmpty {
                        notes.append(Note(text: newNote))
                        newNote = ""
                        UserDefaults.standard.saveNotes(notes)
                    }
                }
                .foregroundColor(.yellow)
                
                List {
                    ForEach(notes) { note in
                        Text(note.text)
                            .foregroundColor(.white)
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
