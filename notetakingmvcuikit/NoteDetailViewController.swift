//
//  NoteDetailViewController.swift
//  notetakingmvcuikit
//
//  VIEW LAYER - MVC Architecture
//
//  This View Controller handles the detailed view for creating/editing notes
//  It demonstrates how a VIEW:
//  - Presents UI elements for user interaction
//  - Captures user input (text editing)
//  - Communicates with CONTROLLER when user performs actions
//  - Updates display based on data received from CONTROLLER
//

import UIKit
import CoreData

// MARK: - Note Detail View Controller
class NoteDetailViewController: UIViewController {
    
    // MARK: - UI Components (View Elements)
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    // MARK: - Controller Reference
    var notesController: NotesController!
    
    // MARK: - Data Properties
    var noteToEdit: NoteEntity? // If editing existing note
    var isCreatingNew: Bool = true
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupController()
        populateFields()
    }
    
    // MARK: - View Setup (VIEW responsibility)
    private func setupView() {
        // Configure navigation
        title = isCreatingNew ? "New Note" : "Edit Note"
        
        // Beautiful background
        view.backgroundColor = DesignSystem.Colors.backgroundPrimary
        
        // Navigation bar buttons are already configured in storyboard
        setupNavigationBar()
        
        // Apply beautiful styling to text elements
        titleTextField.applyModernStyle()
        titleTextField.placeholder = "Enter note title..."
        titleTextField.font = DesignSystem.Typography.title
        
        contentTextView.applyModernStyle()
        contentTextView.font = DesignSystem.Typography.body
        contentTextView.textColor = DesignSystem.Colors.textPrimary
        
        // Add gradient background to the view
        DispatchQueue.main.async {
            self.view.addGradientBackground(
                colors: [
                    DesignSystem.Colors.gradientStart.withAlphaComponent(0.1),
                    DesignSystem.Colors.gradientEnd.withAlphaComponent(0.05)
                ],
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 1, y: 1)
            )
        }
    }
    
    private func setupNavigationBar() {
        // Beautiful navigation bar styling
        navigationController?.navigationBar.tintColor = DesignSystem.Colors.primary
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.textPrimary,
            .font: DesignSystem.Typography.navigationTitle
        ]
    }
    
    // MARK: - Controller Setup
    private func setupController() {
        // Connect to controller if not already set
        if notesController == nil {
            notesController = NotesController()
        }
    }
    
    // MARK: - Data Population (VIEW displays data from MODEL via CONTROLLER)
    private func populateFields() {
        guard let note = noteToEdit else {
            // Creating new note - leave fields empty with placeholder
            titleTextField.text = ""
            contentTextView.text = "Start writing your note here...\n\nThis beautiful interface demonstrates the VIEW layer in MVC architecture - it handles display and user input while staying independent of business logic."
            contentTextView.textColor = DesignSystem.Colors.textSecondary
            return
        }
        
        // Editing existing note - populate with existing data
        titleTextField.text = note.title
        contentTextView.text = note.content
        contentTextView.textColor = DesignSystem.Colors.textPrimary
        isCreatingNew = false
    }
    
    // MARK: - User Actions (VIEW captures input and sends to CONTROLLER)
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // Get user input from UI elements
        let title = titleTextField.text ?? ""
        let content = contentTextView.text ?? ""
        
        // Clear placeholder text if it's still there
        let cleanContent = content.hasPrefix("Start writing your note here...") ? "" : content
        
        if isCreatingNew {
            // VIEW asks CONTROLLER to create new note
            notesController.createNote(title: title, content: cleanContent)
        } else {
            // VIEW asks CONTROLLER to update existing note
            if let note = noteToEdit {
                notesController.updateNote(note, title: title, content: cleanContent)
            }
        }
        
        // Beautiful exit animation
        UIView.animate(withDuration: DesignSystem.Animation.quick) {
            self.view.alpha = 0.8
            self.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            // Return to previous view
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        // User cancelled - just dismiss without saving
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Text Field Delegate (VIEW handles user input)
extension NoteDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Move focus to content text view when user taps return on title
        contentTextView.becomeFirstResponder()
        return true
    }
}