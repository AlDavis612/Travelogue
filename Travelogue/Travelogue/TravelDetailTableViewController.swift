//
//  TravelDetailTableViewController.swift
//  Travelogue
//
//  Created by Alex Davis on 12/4/19.
//  Copyright © 2019 Alex Davis. All rights reserved.
//

import UIKit

class TravelDetailTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    let dateFormatter = DateFormatter()
    let newLogDateFormatter = DateFormatter()
    let imagePickerController = UIImagePickerController()
    
    var log: Log?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyTextView.layer.borderWidth = 1.0
        bodyTextView.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        bodyTextView.layer.cornerRadius = 6.0
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        newLogDateFormatter.dateStyle = .medium
        
        if let log = log {
            titleTextField.text = log.title
            bodyTextView.text = log.body
            if let addDate = log.addDate {
                dateLabel.text = dateFormatter.string(from: addDate)
            }
            image = log.image
            imageView.image = image
        } else {
            titleTextField.text = ""
            bodyTextView.text = ""
            dateLabel.text = newLogDateFormatter.string(from: Date(timeIntervalSinceNow: 0))
            imageView.image = nil
        }
    }

    @IBAction func selectImage(_ sender: Any) {
        selectImageSource()
    }

    func selectImageSource() {
        let alert = UIAlertController(title: "Choose a Method of Selection", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            (alertAction) in
            self.takePhotoUsingCamera()
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            (alertAction) in
            self.selectPhotoFromLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func selectPhotoFromLibrary() {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            imagePickerController.dismiss(animated: true, completion: nil)
        }
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        image = selectedImage
        imageView.image = image
        if let log = log {
            log.image = selectedImage
        }
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func takePhotoUsingCamera() {
        if (!UIImagePickerController.isSourceTypeAvailable(.camera)) {
            alertNotifyUser(message: "This device has no camera.")
            return
        }
        
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespaces), !title.isEmpty else {
            alertNotifyUser(message: "Please enter a title before saving the log.")
            return
        }
        
        if let log = log {
            log.title = title
            log.body = bodyTextView.text
            log.image = image
          
        } else {
            log = Log(title: title, body: bodyTextView.text, image: image)
        }
        
        if let log = log {
            do {
                let managedContext = log.managedObjectContext
                try managedContext?.save()
            } catch {
                alertNotifyUser(message: "The log save failed.")
            }
            
        } else {
            alertNotifyUser(message: "The log creation failed.")
        }
        
        navigationController?.popViewController(animated: true)
    }
}
