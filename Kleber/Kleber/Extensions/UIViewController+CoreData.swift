//
//  UIViewController+CoreData.swift
//  Kleber
//
//  Created by user132969 on 10/22/17.
//  Copyright © 2017 user132969. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
}
