//
//  UploadViewContoller.swift
//  Exchange-O-Shuffle
//
//  Created by jacob stimes  & ian mcdowell on 1/18/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import UIKit
import Alamofire

class UploadViewContoller: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var captionTextField: UITextField!
    
    @IBOutlet weak var authorTextField: UITextField!
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var image: UIImage?
    var caption: String?
    var author: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        captionTextField.delegate = self
        authorTextField.delegate = self
        submitButton.enabled = false
        
        cancelButton.target = self
        cancelButton.action = "closeViewController"

    }
    
    //For returning to main view controller
    // Even if a photo is uploaded, the main view controller won't reload new posts...
    func closeViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Checks if all necessary info has been supplied, and enables the submit button if so
    func checkEnableSubmit(){
        if image != nil && caption != nil && !caption!.isEmpty && author != nil && !author!.isEmpty {
            submitButton.enabled = true
        }
    }
    
    //Select an image from phone's photos
    @IBAction func chooseImageClicked(sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        
        // Pick photos from phone only
        imagePickerController.sourceType = .PhotoLibrary
        
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    //Send image & text to the server to be saved
    // button can't be clicked until all data fields are populated
    @IBAction func submitClicked(sender: UIBarButtonItem) {
        
        //ensures image data is not too large
        let image = resizeImage(self.image!)
        
        let parameters = [
            "caption": self.caption!,
            "author": self.author!
        ]
        
        Alamofire.upload(Alamofire.Method.POST, Networking.baseUrl + Networking.postEndpoint, multipartFormData: { (form) -> Void in
            
            // convert image to JPEG and add it to the body of the request
            if let imageData = UIImageJPEGRepresentation(image, 0.8) {
                form.appendBodyPart(data: imageData, name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            }
            
            // other parameters
            for parameter in parameters.keys {
                if let value = parameters[parameter] {
                    if let data = value.dataUsingEncoding(NSUTF8StringEncoding) {
                        form.appendBodyPart(data: data, name: parameter)
                    }
                }
            }
            
            }, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _) :
                    // encoding was successful, so send the request
                    upload.responseData { response in
                        self.photoSubmitted()
                    }
                case .Failure(let encodingError):
                    // encoding the request failed
                    print(encodingError)
                }
        })
        
    }
    
    //Runs after photo submitted successfully
    func photoSubmitted(){
        let alert = UIAlertController(title: "Exchange-O-Shuffle", message: "Photo submitted!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
            self.closeViewController()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage)-> UIImage{
        let size = CGSizeMake(1000, 1000)
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == captionTextField {
            caption = textField.text
        }
        else if textField == authorTextField {
            author = textField.text
        }
        
        checkEnableSubmit()
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.imageView.image = self.image
        dismissViewControllerAnimated(true, completion: nil)
        checkEnableSubmit();
    }
    
}
