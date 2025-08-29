//
//  NotesListViewController.swift
//  notetakingmvcuikit
//
//  VIEW LAYER - MVC Architecture
//
//  The VIEW is responsible for:
//  - Displaying data to the user (UI components)
//  - Capturing user interactions (button taps, text input)
//  - Updating the display when data changes
//  - Being "dumb" - it doesn't contain business logic
//
//  Key MVC Principle: Views should never directly communicate with Models
//  They communicate through Controllers
//

import UIKit
import CoreData

// MARK: - Notes List View Controller
// This ViewController acts as the VIEW in MVC architecture
// It's responsible for displaying the list of notes to the user
class NotesListViewController: UIViewController {
    
    // MARK: - UI Components (View Elements)
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Controller Reference
    // The View holds a reference to its Controller
    // This allows the View to communicate user actions to the Controller
    var notesController: NotesController!
    
    // MARK: - Data Source
    // This array holds the data to display (received from Controller)
    private var notes: [NoteEntity] = []
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupController()
        loadNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh notes list when returning to this view
        loadNotes()
    }
    
    // MARK: - View Setup (VIEW responsibility)
    private func setupView() {
        title = "Notes"
        
        // Apply beautiful background
        view.backgroundColor = DesignSystem.Colors.backgroundPrimary
        
        // Configure table view with beautiful styling
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.backgroundColor = DesignSystem.Colors.backgroundPrimary
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        // Beautiful navigation styling
        setupNavigationBar()
        
        // Navigation bar button is already configured in storyboard
    }
    
    private func setupNavigationBar() {
        // Beautiful navigation bar styling
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = DesignSystem.Colors.primary
        
        // Custom title attributes
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.textPrimary,
            .font: DesignSystem.Typography.appTitle
        ]
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.textPrimary,
            .font: DesignSystem.Typography.navigationTitle
        ]
    }
    
    // MARK: - Controller Setup
    private func setupController() {
        // Initialize the Controller and establish the connection
        // This is where VIEW connects to CONTROLLER
        notesController = NotesController()
        notesController.view = self // Controller needs reference to update the view
    }
    
    // MARK: - Data Loading (VIEW asks CONTROLLER for data)
    private func loadNotes() {
        // VIEW asks CONTROLLER to provide data
        // This is the proper MVC flow: View -> Controller -> Model
        notes = notesController.getAllNotes()
        
        // Update UI on main thread
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - User Actions (VIEW captures user input and sends to CONTROLLER)
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        // When user taps add button, VIEW notifies CONTROLLER
        notesController.userWantsToCreateNote()
    }
}

// MARK: - Table View Data Source (VIEW responsibility)
extension NotesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "NoteCell")
        
        let note = notes[indexPath.row]
        
        // Apply beautiful card styling to cell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        // Create beautiful card container
        let cardView = UIView()
        cardView.applyCardStyle()
        cardView.backgroundColor = UIColor(hexString: note.colorHex ?? "#4ECDC4") ?? DesignSystem.Colors.backgroundCard
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove existing card views
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.addSubview(cardView)
        
        // Create labels with beautiful typography
        let titleLabel = UILabel()
        titleLabel.text = (note.title?.isEmpty ?? true) ? "Untitled Note" : note.title
        titleLabel.font = DesignSystem.Typography.noteTitle
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        
        let contentLabel = UILabel()
        contentLabel.text = note.content
        contentLabel.font = DesignSystem.Typography.noteContent
        contentLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        contentLabel.numberOfLines = 3
        
        let dateLabel = UILabel()
        if let updatedAt = note.updatedAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: updatedAt)
        }
        dateLabel.font = DesignSystem.Typography.noteDate
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        
        // Add favorite indicator
        let favoriteIcon = UILabel()
        favoriteIcon.text = note.isFavorite ? "⭐" : ""
        favoriteIcon.font = UIFont.systemFont(ofSize: 16)
        
        // Create stack view for labels
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, contentLabel, dateLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        
        favoriteIcon.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(labelStack)
        cardView.addSubview(favoriteIcon)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
            
            labelStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            labelStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            labelStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -50),
            labelStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            favoriteIcon.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            favoriteIcon.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
        ])
        
        return cell
    }
}

// MARK: - Table View Delegate (VIEW handles user interactions)
extension NotesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedNote = notes[indexPath.row]
        // VIEW notifies CONTROLLER about user selection
        notesController.userSelectedNote(selectedNote)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let noteToDelete = notes[indexPath.row]
            // VIEW notifies CONTROLLER about delete action
            notesController.userWantsToDelete(note: noteToDelete)
        }
    }
}

// MARK: - View Update Protocol
// This protocol defines how the CONTROLLER can update the VIEW
// This is a key part of MVC communication
protocol NotesListViewProtocol: AnyObject {
    func refreshNotesList()
    func showError(message: String)
}

// MARK: - Protocol Implementation
extension NotesListViewController: NotesListViewProtocol {
    
    // CONTROLLER calls this method to tell VIEW to refresh
    func refreshNotesList() {
        loadNotes()
    }
    
    // CONTROLLER calls this method to tell VIEW to show an error
    func showError(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}