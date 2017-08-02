//
//  UserDetailViewController.swift
//  CoreDataDemo
//
//  Created by Sanjeet Verma on 26/07/17.
//  Copyright © 2017 Sanjeet Verma. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import CoreData
class UserDetailViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var ProfileImage:UIImage!
    var username:String?
    var userEmailaddress:String?
    var usercontact:String?
    var userAddress:String?
    var editBool = false
    var employee : Employee?

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var phoneTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var addressTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var nameTextField: SkyFloatingLabelTextFieldWithIcon!
    
    var managedObjectContext : NSManagedObjectContext? {
    
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if editBool == true && employee != nil{
        
            nameTextField.text = employee?.name
            phoneTextField.text = employee?.phone
            addressTextField.text = employee?.address
            emailTextField.text = employee?.email
            btnProfilePic.setImage(UIImage(data: employee?.profileImage as! Data), for: .normal)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    override func viewDidLayoutSubviews() {
        
        btnProfilePic.layer.cornerRadius = self.btnProfilePic.frame.size.height/2
        btnProfilePic.clipsToBounds = true
        
        submitButton.layer.cornerRadius = self.submitButton.frame.size.height/2
        submitButton.clipsToBounds = true
        
        nameTextField.iconImage.image = UIImage(named:"IconUser")
        nameTextField.iconWidth = 30
        nameTextField.iconHeight = 30
        
        phoneTextField.iconImage.image = UIImage(named:"IconPhone")
        phoneTextField.iconWidth = 30
        phoneTextField.iconHeight = 30
        
        addressTextField.iconImage.image = UIImage(named:"IconPhone")
        addressTextField.iconWidth = 30
        addressTextField.iconHeight = 30
        
        emailTextField.iconImage.image = UIImage(named:"IconEmail")
        emailTextField.iconWidth = 30
        emailTextField.iconHeight = 22
        
    }
    
    @IBAction func onClickProfileAction(_ sender: Any) {
        
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.isEditing = false
            
            let actionSheet =  UIAlertController(title: "Select Profile Photo", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.default){ (libSelected) in
                
                
                
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            actionSheet.addAction(libButton)
            let cameraButton = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.default) { (camSelected) in
                
                if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
                {
                    imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                    self.present(imagePicker, animated: true, completion: nil)
                }
                else
                {
                    actionSheet.dismiss(animated: false, completion: nil)
                    let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
                        
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                }
                
            }
            actionSheet.addAction(cameraButton)
            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (cancelSelected) in
                
            }
            actionSheet.addAction(cancelButton)
            let albumButton = UIAlertAction(title: "Saved Album", style: UIAlertActionStyle.default) { (albumSelected) in
                
                imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
                self.present(imagePicker, animated: true, completion: nil)
                
            }
            actionSheet.addAction(albumButton)
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                actionSheet.popoverPresentationController?.sourceView = self.view
                actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
                
                self.present(actionSheet, animated: true, completion: nil)
            }
            else
            {
                self.present(actionSheet, animated: true, completion:nil)
            }
    }
    
    //MARK: - UIImagepicker delegate
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let PickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            btnProfilePic.setImage(PickedImage, for: .normal)
            ProfileImage = PickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickSubmitAction(_ sender: Any) {
        
        if nameTextField.text!.isEmpty || phoneTextField.text!.isEmpty || addressTextField.text!.isEmpty || emailTextField.text!.isEmpty || ProfileImage == nil{
        
            let alertController = UIAlertController(title: "OOPS!", message: "You need to give the all information required to save this User", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        }else{
        
            if let moc = managedObjectContext{
            
                let employee = Employee(context: moc)
                employee.name = nameTextField.text
                employee.phone = phoneTextField.text
                employee.email = emailTextField.text
                employee.address = addressTextField.text
                if let data = UIImageJPEGRepresentation(ProfileImage, 0.9){
                
                employee.profileImage = data as NSData
                }
                
                savetoCoreData(){
                    
                    self.navigationController!.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    
    func savetoCoreData(completion:@escaping()->Void){
        
        managedObjectContext?.perform({ 
          
            do{
                
                try self.managedObjectContext?.save()
                completion()
                print("Employee details save into Core data")
            }catch {
                
                print("Could not saved the data:\(error.localizedDescription)")
            }
        })
    }
    
    
    @IBAction func onClickUpdateAction(_ sender: Any) {
        
        employee?.name = nameTextField.text
        employee?.phone = phoneTextField.text
        employee?.email = emailTextField.text
        employee?.address = addressTextField.text

        if let data = UIImageJPEGRepresentation((btnProfilePic.imageView?.image)!, 0.9){
            
            employee?.profileImage = data as NSData
        }
        
        savetoCoreData(){
            
            self.navigationController!.popToRootViewController(animated: true)
        }
    }
    
    
}
