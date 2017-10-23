//
//  ComprasTableViewController.swift
//  Kleber
//
//  Created by user132969 on 10/21/17.
//  Copyright © 2017 user132969. All rights reserved.
//

import UIKit
import CoreData

class ComprasTableViewController: UITableViewController {
    
    // MARK: - Properties
    var dataSource: [Product] = []
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Sua lista está vazia!"
        label.textAlignment = .center
        label.textColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        loadProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProducts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CompraRegisterViewController, let index = tableView.indexPathForSelectedRow {
            vc.product = dataSource[index.row]
        }
    }
    
    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = (dataSource.count == 0) ? label : nil
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        let product = dataSource[indexPath.row]
        if let image = product.photo as? UIImage {
            cell.ivPhoto.image = image
        } else {
            cell.ivPhoto.image = nil
        }
        cell.lbName.text = product.name
        cell.lbPrice.text = "R$ \(product.price)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = dataSource[indexPath.row]
            context.delete(product)
            do {
                try context.save()
                loadProducts()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
