//
//  ViewController.swift
//  MemeMe1
//
//  Created by MOLINYAWE, JUSTIN L on 8/26/19.
//  Copyright © 2019 molinyawe. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var libraryButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memeImage: UIImage
    }
    
    let topDefaultValue = "TOP"
    let bottomDefaultValue = "BOTTOM"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureTextField(topTextField, text: topDefaultValue)
        configureTextField(bottomTextField, text: bottomDefaultValue)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = mainImageView.image != nil
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    @IBAction func selectImage(_ sender: Any) {
        pickImage(UIImagePickerController.SourceType.photoLibrary)
    }
    
    @IBAction func takeImageFromCamera(_ sender: Any) {
        pickImage(UIImagePickerController.SourceType.camera)
    }
    
    func pickImage(_ source: UIImagePickerController.SourceType) {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = source
        present(imageController, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme() {
        configureTextField(topTextField, text: topDefaultValue)
        configureTextField(bottomTextField, text: bottomDefaultValue)
        shareButton.isEnabled = false
        mainImageView.image = nil
    }
    
    func configureTextField(_ textField: UITextField, text: String) {
        textField.text = text
        textField.delegate = self
        textField.defaultTextAttributes = [
            .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.black,
            .strokeWidth: -4
        ]
        textField.textAlignment = .center // Had to set this after setting the defaultTextAttributes, otherwise it would not center
    }
    
    func setTextFieldToDefault() {
        topTextField.text = topDefaultValue
        bottomTextField.text = bottomDefaultValue
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            mainImageView.image = image
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Clear default text when editing
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == topDefaultValue || textField.text == bottomDefaultValue {
            textField.text = ""
        }
    }
    
    // MARK: Set empty fields back to default
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            if textField == topTextField {
                textField.text = topDefaultValue
            } else if textField == bottomTextField {
                textField.text = bottomDefaultValue
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        topToolbar.isHidden = false
        bottomToolbar.isHidden = false
        
        return memedImage
    }
    
    @IBAction func share() {
        // Generate image
        let memeImage = generateMemedImage()
        
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: mainImageView.image!, memeImage: memeImage)
        let activityViewController = UIActivityViewController(activityItems: [meme.memeImage], applicationActivities: [])
        activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                self.save(meme)
                return
            }
        }
        present(activityViewController, animated: true)
    }
    
    // TODO: Not sure what to do with this portion
    func save(_ meme: Meme) {
        
    }

}

