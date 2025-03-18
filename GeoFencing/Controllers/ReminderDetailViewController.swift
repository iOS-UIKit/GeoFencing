//
//  ReminderDetailViewController.swift
//  GeoFencing
//
//  Created by Sameed Ansari on 18/03/2025.
//

import UIKit
import MapKit

protocol ReminderDetailViewControllerDelegate: AnyObject {
    func didSaveReminder(_ reminder: GeoFenceReminder)
}

class ReminderDetailViewController: UIViewController {
    
    weak var delegate: ReminderDetailViewControllerDelegate?
    
    private let location: Location
    private let remindersViewModel: RemindersViewModel
    private var selectedRadius: Double = 100.0
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let locationNameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let mapPreview = MKMapView()
    private let radiusSlider = RadiusSliderView()
    private let radiusCircleOverlay = MKCircle()
    private let noteTextField = UITextField()
    private let saveButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
    init(location: Location, remindersViewModel: RemindersViewModel) {
        self.location = location
        self.remindersViewModel = remindersViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configureViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(locationNameLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(mapPreview)
        contentView.addSubview(radiusSlider)
        contentView.addSubview(noteTextField)
        contentView.addSubview(saveButton)
        contentView.addSubview(cancelButton)
        
        let annotation = LocationAnnotation(location: location)
        mapPreview.addAnnotation(annotation)
        
        let circle = MKCircle(center: location.coordinate, radius: selectedRadius)
        mapPreview.addOverlay(circle)
        
        let region = MKCoordinateRegion(center: location.coordinate, 
                                        latitudinalMeters: selectedRadius * 4, 
                                        longitudinalMeters: selectedRadius * 4)
        mapPreview.setRegion(region, animated: true)
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        locationNameLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        mapPreview.translatesAutoresizingMaskIntoConstraints = false
        radiusSlider.translatesAutoresizingMaskIntoConstraints = false
        noteTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            locationNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            locationNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            categoryLabel.topAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            mapPreview.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20),
            mapPreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mapPreview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mapPreview.heightAnchor.constraint(equalToConstant: 200),
            
            radiusSlider.topAnchor.constraint(equalTo: mapPreview.bottomAnchor, constant: 20),
            radiusSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            radiusSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            radiusSlider.heightAnchor.constraint(equalToConstant: 50),
            
            noteTextField.topAnchor.constraint(equalTo: radiusSlider.bottomAnchor, constant: 20),
            noteTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            noteTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            noteTextField.heightAnchor.constraint(equalToConstant: 44),
            
            saveButton.topAnchor.constraint(equalTo: noteTextField.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 200),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureViews() {
        titleLabel.text = "Set Geofence Reminder"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        
        locationNameLabel.text = location.name
        locationNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        categoryLabel.text = location.category
        categoryLabel.font = UIFont.systemFont(ofSize: 16)
        categoryLabel.textColor = .secondaryLabel
        
        mapPreview.isZoomEnabled = false
        mapPreview.isScrollEnabled = false
        mapPreview.isUserInteractionEnabled = false
        mapPreview.layer.cornerRadius = 8
        mapPreview.clipsToBounds = true
        mapPreview.delegate = self
        
        radiusSlider.delegate = self
        
        noteTextField.placeholder = "Add a note for this reminder"
        noteTextField.borderStyle = .roundedRect
        noteTextField.delegate = self
        
        saveButton.setTitle("Save Reminder", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = .systemGray5
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.layer.cornerRadius = 10
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    @objc private func saveButtonTapped() {
        let note = noteTextField.text ?? ""
        
        if let reminder = remindersViewModel.createReminder(
            for: location,
            radius: selectedRadius,
            note: note
        ) {
            delegate?.didSaveReminder(reminder)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateRadiusOverlay() {
        mapPreview.removeOverlays(mapPreview.overlays)
        
        let circle = MKCircle(center: location.coordinate, radius: selectedRadius)
        mapPreview.addOverlay(circle)
        
        let region = MKCoordinateRegion(center: location.coordinate, 
                                        latitudinalMeters: selectedRadius * 3, 
                                        longitudinalMeters: selectedRadius * 3)
        mapPreview.setRegion(region, animated: true)
    }
}

extension ReminderDetailViewController: RadiusSliderDelegate {
    func radiusDidChange(radius: Double) {
        selectedRadius = radius
        updateRadiusOverlay()
    }
}

extension ReminderDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
            circleRenderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.2)
            circleRenderer.strokeColor = UIColor.systemBlue
            circleRenderer.lineWidth = 1.0
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension ReminderDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
} 
