//
//  Note.swift
//  notetakingmvcuikit
//
//  MODEL LAYER - MVC Architecture
//
//  The MODEL represents the data and business logic of the application.
//  It is responsible for:
//  - Defining the structure of data (Note properties)
//  - Providing methods to manipulate data
//  - Being independent of the UI (View) and user interactions (Controller)
//
//  Key MVC Principle: The Model should never directly interact with the View
//  It communicates with the Controller, which then updates the View
//

import Foundation

// MARK: - Note Model
// This struct represents a single Note entity in our application
// It contains all the properties that define what a Note is
struct Note {
    let id: UUID           // Unique identifier for each note
    var title: String      // Note title
    var content: String    // Note content/body
    var createdAt: Date    // When the note was created
    var updatedAt: Date    // When the note was last modified
    
    // Initializer for creating new notes
    init(title: String, content: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Method to update note content (business logic in Model)
    mutating func update(title: String, content: String) {
        self.title = title
        self.content = content
        self.updatedAt = Date()
    }
}

// MARK: - NoteDataManager (Model Layer)
// This class handles all data operations for Notes
// It acts as the data source and implements business rules
// In MVC, this is still part of the Model layer because it handles data logic
class NoteDataManager {
    
    // MARK: - Properties
    private var notes: [Note] = []  // Private array to store notes
    
    // MARK: - Singleton Pattern
    // Using singleton to ensure there's only one data manager instance
    // This makes it easy to share data across different Controllers
    static let shared = NoteDataManager()
    private init() {
        loadSampleData() // Load some sample notes
    }
    
    // MARK: - Data Operations (Model Business Logic)
    
    // CREATE: Add a new note
    func createNote(title: String, content: String) -> Note {
        let newNote = Note(title: title, content: content)
        notes.append(newNote)
        return newNote
    }
    
    // READ: Get all notes
    func getAllNotes() -> [Note] {
        return notes.sorted { $0.updatedAt > $1.updatedAt } // Most recent first
    }
    
    // READ: Get a specific note by ID
    func getNote(by id: UUID) -> Note? {
        return notes.first { $0.id == id }
    }
    
    // UPDATE: Modify an existing note
    func updateNote(id: UUID, title: String, content: String) -> Bool {
        guard let index = notes.firstIndex(where: { $0.id == id }) else {
            return false // Note not found
        }
        notes[index].update(title: title, content: content)
        return true
    }
    
    // DELETE: Remove a note
    func deleteNote(id: UUID) -> Bool {
        guard let index = notes.firstIndex(where: { $0.id == id }) else {
            return false // Note not found
        }
        notes.remove(at: index)
        return true
    }
    
    // MARK: - Sample Data
    private func loadSampleData() {
        let sampleNote1 = Note(title: "Welcome to MVC Notes", 
                              content: "This app demonstrates the Model-View-Controller architecture pattern.")
        let sampleNote2 = Note(title: "Understanding MVC", 
                              content: "Model handles data, View handles UI, Controller coordinates between them.")
        notes = [sampleNote1, sampleNote2]
    }
}