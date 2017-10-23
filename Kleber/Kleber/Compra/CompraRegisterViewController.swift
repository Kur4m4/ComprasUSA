//
//  CompraRegisterViewController.swift
//  Kleber
//
//  Created by user132969 on 10/21/17.
//  Copyright © 2017 user132969. All rights reserved.
//

import UIKit
import CoreData

class CompraRegisterViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var swCard: UISwitch!
    @IBOutlet weak var btAddUpdate: UIButton!
    
    // MARK: - Properties
    var product: Product!
    var smallImage: UIImage!
    var pickerView: UIPickerView!
    var dataSource: [State] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if product != nil {
            tfName.text = product.name
            if let image = product.photo as? UIImage {
                ivPhoto.image = image
                smallImage = image
            }
            tfState.text = product.state?.name
            tfPrice.text = "\(product.price)"
            swCard.setOn(product.card, animated: false)
            btAddUpdate.setTitle("Atualizar", for: .normal)
        }
        
        // TapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.addProductPhoto(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        ivPhoto.addGestureRecognizer(tapGesture)
        ivPhoto.isUserInteractionEnabled = true
        
        // UIPickerView
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        //Criando uma toobar que servirá de apoio ao pickerView.
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        //O botão abaixo servirá para o usuário cancelar a escolha, chamando o método cancel
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        //O botão done confirmará a escolha do usuário, chamando o método done.
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        //Aqui definimos que o pickerView será usado como entrada do textField
        tfState.inputView = pickerView
        
        //Definindo a toolbar como view de apoio do textField (view que fica acima do teclado)
        tfState.inputAccessoryView = toolbar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
            pickerView.reloadAllComponents()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - IBActions
    @IBAction func addUpdateProduct(_ sender: UIButton) {
        if tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "", smallImage != nil, tfState.text != "" {
            if product == nil {
                product = Product(context: context)
            }
            if let price = Double(tfPrice.text!.replacingOccurrences(of: ",", with: ".")) {
                product.name = tfName.text
                product.photo = smallImage
                product.state = dataSource[pickerView.selectedRow(inComponent: 0)]
                product.price = price
                product.card = swCard.isOn
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                showAlert(title: "Erro", message: "Valor (U$) não numérico")
            }
        } else {
            showAlert(title: "Aviso", message: "Preencha todos os campos")
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Methods
    func addProductPhoto(_ sender: UITapGestureRecognizer) {
        //Criando o alerta que será apresentado ao usuário
        let alert = UIAlertController(title: "Selecionar poster", message: "De onde você quer escolher o poster?", preferredStyle: .actionSheet)
        
        //Verificamos se o device possui câmera. Se sim, adicionamos a devida UIAlertAction
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        //A UIAlertAction da Biblioteca de fotos também é criada e adicionada
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        //Criando o objeto UIImagePickerController
        let imagePicker = UIImagePickerController()
        
        //Definimos seu sourceType através do parâmetro passado
        imagePicker.sourceType = sourceType
        
        //Definimos a MovieRegisterViewController como sendo a delegate do imagePicker
        imagePicker.delegate = self
        
        //Apresentamos a imagePicker ao usuário
        present(imagePicker, animated: true, completion: nil)
    }
    
    //O método cancel irá esconder o teclado e não irá atribuir a seleção ao textField
    func cancel() {
        
        //O método resignFirstResponder() faz com que o campo deixe de ter o foco, fazendo com que o pickerView desapareça da tela
        tfState.resignFirstResponder()
    }
    
    //O método done irá atribuir ao textField a escolhe feita no pickerView
    func done() {
        
        //Abaixo, recuperamos a linha selecionada na coluna (component) 0 (temos apenas um component em nosso pickerView)
        if !dataSource.isEmpty {
            tfState.text = dataSource[pickerView.selectedRow(inComponent: 0)].name
        }
        cancel()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension CompraRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //O método abaixo nos trará a imagem selecionada pelo usuário em seu tamanho original
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        
        //Iremos usar o código abaixo para criar uma versão reduzida da imagem escolhida pelo usuário
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        
        //Atribuímos a versão reduzida da imagem à variável smallImage
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivPhoto.image = smallImage //Atribuindo a imagem à ivProductPhoto
        
        //Aqui efetuamos o dismiss na UIImagePickerController, para retornar à tela anterior
        dismiss(animated: true, completion: nil)
    }
}

extension CompraRegisterViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //Retornando o texto recuperado do objeto dataSource, baseado na linha selecionada
        return dataSource[row].name
    }
}

extension CompraRegisterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
}
