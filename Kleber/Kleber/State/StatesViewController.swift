//
//  StatesViewController.swift
//  Kleber
//
//  Created by user132969 on 10/22/17.
//  Copyright © 2017 user132969. All rights reserved.
//

import UIKit
import CoreData

enum StateAlertType {
    case add
    case edit
}

class StatesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tfDolar: UITextField!
    @IBOutlet weak var tfIof: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var dataSource: [State] = []
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Lista de estados vazia."
        label.textAlignment = .center
        label.textColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        loadStates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tfDolar.text = UserDefaults.standard.string(forKey: "dolar")
        tfIof.text = UserDefaults.standard.string(forKey: "iof")
    }
    
    // MARK: - Methods
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func showAlert(type: StateAlertType, state: State?) {
        let title = (type == .add) ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do estado"
            if let name = state?.name {
                textField.text = name
            }
        }
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Imposto"
            textField.keyboardType = .decimalPad
            if let imposto = state?.imposto {
                textField.text = "\(imposto)"
            }
        }
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            if alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "", let tax = alert.textFields?.last?.text {
                if let imposto = Double(tax.replacingOccurrences(of: ",", with: ".")) {
                    let state = state ?? State(context: self.context)
                    state.name = alert.textFields?.first?.text
                    state.imposto = imposto
                    do {
                        try self.context.save()
                        self.loadStates()
                    } catch {
                        print(error.localizedDescription)
                    }
                } else {
                    self.showAlert(any: alert, title: "Erro", message: "Imposto não numérico")
                }
            } else {
                self.showAlert(any: alert, title: "Aviso", message: "Preencha todos os campos")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(any: Any, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (actipn: UIAlertAction) in
            if let alertController = any as? UIAlertController {
                self.present(alertController, animated: true, completion: nil)
            } else if let textField = any as? UITextField {
                textField.becomeFirstResponder()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func setDollarQuotation(_ sender: UITextField) {
        if let dollarQuotation = Double(tfDolar.text!.replacingOccurrences(of: ",", with: ".")) {
            UserDefaults.standard.set(dollarQuotation, forKey: "dolar")
        } else {
            tfDolar.text = UserDefaults.standard.string(forKey: "dolar")
            showAlert(any: tfDolar, title: "Erro", message: "Cotação do dólar (R$) não numérica")
        }
    }
    
    @IBAction func setIofTax(_ sender: UITextField) {
        if let iofTax = Double(tfIof.text!.replacingOccurrences(of: ",", with: ".")) {
            UserDefaults.standard.set(iofTax, forKey: "iof")
        } else {
            tfIof.text = UserDefaults.standard.string(forKey: "iof")
            showAlert(any: tfIof, title: "Erro", message: "IOF (%) não numérico")
        }
    }
    
    @IBAction func addState(_ sender: UIButton) {
        showAlert(type: .add, state: nil)
    }
}

extension StatesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = dataSource[indexPath.row]
        showAlert(type: .edit, state: state)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.dataSource[indexPath.row]
            self.context.delete(state)
            do {
                try self.context.save()
                self.dataSource.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print(error.localizedDescription)
            }
        }
        return [deleteAction]
    }
}

extension StatesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = (dataSource.count == 0) ? label : nil
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let state = dataSource[indexPath.row]
        cell.textLabel?.text = state.name
        cell.detailTextLabel?.text = "\(state.imposto)"
        return cell
    }
}
