//
//  UserListViewController.swift
//  CoreDataDemo
//
//  Created by Sanjeet Verma on 26/07/17.
//  Copyright © 2017 Sanjeet Verma. All rights reserved.
//

import UIKit
import CoreData
class UserListViewController: UIViewController{

    @IBOutlet weak var UserTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var NotFound: UILabel!
    var employeeArray = [Employee]()
    var filtered = [Employee]()
    var searchActive : Bool = false
    var EditActionFlag = false
    var managedObjectContext : NSManagedObjectContext?{
    
        return(UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        UserTableView.tableFooterView = UIView(frame: .zero)
        UserTableView.showsVerticalScrollIndicator = false
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        retrieveEmployeeData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    
    override func viewDidLayoutSubviews() {
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationItem.title = ""
    }
    
    @IBAction func onClickAddAction(_ sender: UIBarButtonItem) {
        
        self.EditActionFlag = false
        self.performSegue(withIdentifier: "DetailSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if self.EditActionFlag == true{
        
            let userDetail: UserDetailViewController = segue.destination as! UserDetailViewController
            
            userDetail.employee = employeeArray[(sender as! IndexPath).row]
            userDetail.editBool = true
        }
    }
    
    func retrieveEmployeeData(){
        
        
        fetchuserfromCoreData { (employees) in
            
            if let employee = employees{
            
                self.employeeArray = employee
                self.UserTableView.reloadData()
            }
        }
    }
    
    func fetchuserfromCoreData(completion:([Employee]?)-> Void){
        
        var results = [Employee]()
        let request : NSFetchRequest<Employee> = Employee.fetchRequest()
        
        do{
        
           results = try managedObjectContext!.fetch(request)
            completion(results)
        }catch {
        
            print("Could not fetch data from Core data")
        }
        
    }
}

extension UserListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 91
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            if self.employeeArray.count > 0{
            
                self.managedObjectContext?.delete(self.employeeArray[indexPath.row])
                do{
                    
                    try self.managedObjectContext?.save()
                }catch{
                    
                    print("Could not save the data after deletion\(error.localizedDescription)")
                }
                self.employeeArray.remove(at: indexPath.row)
                self.UserTableView.reloadData()
            }else{
            
                let alertController = UIAlertController(title: "OOPS!", message: "Data is not available", preferredStyle:.alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        let Edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            
            self.EditActionFlag = true
            self.performSegue(withIdentifier: "DetailSegue", sender: indexPath)
        }
        
        Edit.backgroundColor = UIColor.darkGray
        
        return [delete, Edit]
    }
    
}

extension UserListViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchActive) {
            
            return filtered.count
        }
        return employeeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UserTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserListCell
        cell.selectionStyle = .none
        
        if(searchActive){
            
            cell.ConfigureCell(employee: filtered[indexPath.row])
        } else {
          
            cell.ConfigureCell(employee: employeeArray[indexPath.row])
        }
        
        //cell.ConfigureCell(employee: employeeArray[indexPath.row])
        return cell
        
    }
}

extension UserListViewController : UISearchBarDelegate{


    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchActive = true
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = false
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.endEditing(true)
        UserTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != ""{
        
            let request : NSFetchRequest<Employee> = Employee.fetchRequest()
            let Searchpredicate = NSPredicate(format: "name contains %@", searchText)
            request.predicate = Searchpredicate
            do{
                
                filtered = try managedObjectContext!.fetch(request)
                if(filtered.count == 0){
                    searchActive = false
                    NotFound.isHidden = false
                    UserTableView.isHidden = true
                } else {
                    searchActive = true;
                    NotFound.isHidden = true
                    UserTableView.isHidden = false
                }
                 UserTableView.reloadData()
            }catch {
                
                print("Could not fetch data from Core data")
            }
        }else{
            
            filtered = employeeArray
            UserTableView.isHidden = false
            UserTableView.reloadData()
        }
    }
}




