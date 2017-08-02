//
//  UserListCell.swift
//  CoreDataDemo
//
//  Created by Sanjeet Verma on 26/07/17.
//  Copyright © 2017 Sanjeet Verma. All rights reserved.
//

import UIKit
import CoreData
class UserListCell: UITableViewCell {

    
    
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var UserImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        UserImageView.layer.cornerRadius = UserImageView.frame.size.height/2
        UserImageView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func ConfigureCell(employee:Employee){
        
        self.userEmail.text = employee.email
        self.userName.text =  employee.name
        if let data = employee.profileImage{
        
            self.UserImageView.image = UIImage(data: data as Data)
        }
        
    }

}
