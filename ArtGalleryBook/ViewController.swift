//
//  ViewController.swift
//  ArtGalleryBook
//
//  Created by Sinan Kulen on 4.06.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
     var nameArray = [String]()
     var idArray = [UUID]()
     
     var selectedPaintings = ""
     var selectedPaintingsId = UUID()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
       
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    @objc func getData(){
        nameArray.removeAll()
        idArray.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
       
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                
                
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                   
                    self.tableView.reloadData()
                    
                }
            }
   
        }catch{
            print("error")
        }

        
    }
    
    
    @objc func addButtonClicked(){
        selectedPaintings = ""
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as! detailVC
            destinationVC.chosenPaintings = selectedPaintings
            destinationVC.chosenPaintingsId = selectedPaintingsId
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPaintings = nameArray[indexPath.row]
        selectedPaintingsId = idArray[indexPath.row]
        
        performSegue(withIdentifier: "toDetailVC", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
        
        
        let idString = idArray[indexPath.row].uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@ ", idString)
        
        do{
        let results = try context?.fetch(fetchRequest)
            if results!.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let id = result.value(forKey: "id") as? UUID{
                        if id ==  idArray[indexPath.row]{
                            context?.delete(result)
                            nameArray.remove(at: indexPath.row)
                            idArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            
                            do{
                                try context?.save()
                            }catch{
                                print("error")
                            }
                            
                            break
                        }
                    }

                }
  
            }
            
            
            
        }catch{
            print ("error")
        }
    }
    
    
    
}
