//
//  detailVC.swift
//  ArtGalleryBook
//
//  Created by Sinan Kulen on 5.06.2021.
//

import UIKit
import CoreData

class detailVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPaintings = ""
    var chosenPaintingsId = UUID()
            
    override func viewDidLoad() {
        super.viewDidLoad()

        if chosenPaintings != "" {
            //Core Data
            
            saveButton.isHidden = true
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingsId.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            
            
            do{
                let results = try context?.fetch(fetchRequest)
                if results!.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }

                }
     
                
            }catch {
                print("error")
            }
       
            
            
        
        }else {
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectimage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selectimage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPaintings = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPaintings.setValue(nameText.text, forKey: "name")
        newPaintings.setValue(artistText.text, forKey: "artist")
        newPaintings.setValue(UUID(), forKey: "id")
        
        if let year = Int(yearText.text!){
            newPaintings.setValue(year, forKey: "year")
        }
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newPaintings.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
        }catch{
            print("error")
        }
       
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)

    }
    
}
