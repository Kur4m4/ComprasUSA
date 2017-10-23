//
//  TotalCompraViewController.swift
//  Kleber
//
//  Created by user132969 on 10/23/17.
//  Copyright © 2017 user132969. All rights reserved.
//

import UIKit
import CoreData

class TotalCompraViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var lbTotalDolar: UILabel!
    @IBOutlet weak var lbTotalReal: UILabel!
    
    // MARK: - Properties
    var dataSource: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProducts()
        calcularTotal()
    }
    
    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func calcularTotal() {
        let cotacaoDolar = Double(UserDefaults.standard.string(forKey: "dolar")!)!
        let iof = Double(UserDefaults.standard.string(forKey: "iof")!)!
        
        var impostos: Double = 0
        var precoConvertido: Double = 0
        var totalDolar: Double = 0
        var totalReal: Double = 0
        
        for product in dataSource {
            totalDolar += product.price
            
            precoConvertido = product.price * cotacaoDolar
            impostos = precoConvertido * product.state!.imposto / 100
            if product.card {
                impostos += precoConvertido * iof / 100
            }
            totalReal += precoConvertido + impostos
        }
        
        lbTotalDolar.text = "\(totalDolar)"
        lbTotalReal.text = "\(totalReal)"
    }
}
