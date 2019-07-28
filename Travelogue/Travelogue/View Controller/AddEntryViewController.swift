//
//  AddEntryViewController.swift
//  Travelogue
//
//  Created by 刘洋 on 7/23/19.
//  Copyright © 2019 Yang Liu. All rights reserved.
//

import UIKit

class AddEntryViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var trip: Trip? = nil
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseDateButton: UIButton!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var photoImage: UIImageView!
    
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter.init()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self
        contentTextField.delegate = self
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        datePicker.datePickerMode = .date
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateString = self.dateFormatter.string(from: self.datePicker.date)
        chooseDateButton.setTitle(dateString, for: .normal)
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func pressChooseDateButton(_ sender: UIButton) {
        let alertController: UIAlertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.view.addSubview(datePicker)
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (alertAction) -> Void in
            let dateString = self.dateFormatter.string(from: self.datePicker.date)
            self.chooseDateButton.setTitle(dateString, for: .normal)
        }
        alertController.addAction(ok)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func pressAddPhotoButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        
        let camere = UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                print("Camera is unavailable!")
            }
        }
        alertController.addAction(camere)
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                print("Photo Library is unavailable!")
            }
        }
        alertController.addAction(photoLibrary)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let url = info[UIImagePickerController.InfoKey.imageURL] as! URL
        self.dismiss(animated: true, completion: {
            do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                self.photoImage.image = image
                self.addPhotoButton.isHidden = true
            } catch let error as NSError {
                print(error)
            }
        })
    }
    
    @objc func insertNewObject(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let entry = Entry(context: context)
        entry.title = titleTextField.text
        entry.date = datePicker.date
        entry.content = contentTextField.text
        
        if let image = photoImage.image {
            let data = UIImage.pngData(image)
            entry.photo = data()
        }
        
        // Save the context
        do {
            self.trip?.addToEntries(entry)
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        showAlert(title: "Done!", message: "New entry has been saved!") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showAlert(title: String, message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle:.alert)
        let ok = UIAlertAction.init(title: "OK", style: UIAlertAction.Style.cancel) { (action: UIAlertAction) -> () in
            completion()
        }
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }

}
