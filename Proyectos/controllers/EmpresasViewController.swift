//
//  ViewController.swift
//  LogoEmpresa
//
//  Created by Desarrollo on 28-12-17.
//  Copyright © 2017 Cristopher Neira. All rights reserved.
//

import UIKit


class Empresas {
    var Nombre_Empresa = ""
    var Codigo_Empresa = ""
}


class EmpresasViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, XMLParserDelegate {
    
    
    
    //...................................................................//
    //..................... VARIABLES Y CONSTANTES ......................//
    //...................................................................//
    
    
    
    //.......................... CONSTANTES .............................//
    
    
    let userDefaults = UserDefaults.standard
    
    
    //........................... VARIABLES .............................//
    
    
    var items = [Empresas]();
    var item = Empresas();
    var foundCharacters = "";
    var SELECTED_EMPRESA = ""
    var SELECTED_NombreEmpresa = ""
    var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let base_url = UserDefaults.standard.value(forKey: "base_url")!
    

    
    //...................................................................//
    //............................ BOTONES ..............................//
    //...................................................................//
    
    
    
    //............................ IBOUTLET .............................//
    
    
    @IBOutlet weak var Mycollection: EmpresasCollectionViewCell!
    @IBOutlet weak var Collection: UICollectionView!
    
    
    
    
    //...................................................................//
    //...................... FUNCIONES VIEW .............................//
    //...................................................................//
    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        self.Collection.delegate = self
        self.Collection.dataSource = self
        
        let url = URL(string: "\(base_url)/getListadoEmpresas")
        
        effectView = activityIndicator(title: "Cargando Información", view: self.view)
        self.view.addSubview(self.effectView)
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            if(data != nil){
                let parser = XMLParser(data: data!)
                parser.delegate = (self as XMLParserDelegate)
                parser.parse()
                
                DispatchQueue.main.async {
                    self.Collection.reloadData()
                    self.effectView.removeFromSuperview()
                }
            }
            else{
                DispatchQueue.main.async {
                    self.Collection.reloadData()
                    let alert = UIAlertController(title: "Error", message: "Problemas de conexión", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Reintentar", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.effectView.removeFromSuperview()
                    self.viewDidLoad()
                }
            }
        }
        
        if(items.count == 0){
            task.resume()
        }
       
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.effectView.removeFromSuperview()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    //...................................................................//
    //................. FUNCIONES COLLECTION VIEW .......................//
    //...................................................................//
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
   
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collection_cell", for: indexPath) as! EmpresasCollectionViewCell
        
        //cell.indicatorDeVerdad.startAnimating()
        
        cell.LblCodigoEmpresa.text = items[indexPath.row].Codigo_Empresa
        cell.LblNombreEmpresa.text = items[indexPath.row].Nombre_Empresa
        
        if let imagen = (userDefaults.object(forKey:"\(items[indexPath.row].Codigo_Empresa).png")) as? Data{
            cell.Myimage.image = UIImage(data: imagen as Data)
            cell.indicatorDeVerdad.stopAnimating()
            cell.indicatorDeVerdad.isHidden = true
            
        }else{
            downloadImage("http://200.111.46.182/WS_MovilProyecto/Imagenes/\( cell.LblCodigoEmpresa.text ?? "").png", inView: cell.Myimage, indicador: cell.indicatorDeVerdad)
        }
        
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.SELECTED_EMPRESA = items[indexPath.row].Codigo_Empresa
        userDefaults.set(self.SELECTED_EMPRESA, forKey: "Cod_Empresa")
        
        self.SELECTED_NombreEmpresa = items[indexPath.row].Nombre_Empresa
        userDefaults.set(self.SELECTED_NombreEmpresa, forKey: "NombreEmpresa")
        
        performSegue(withIdentifier: "empresaSeleccionadaSegue", sender: self)
    }
    
   
    
    
    //...................................................................//
    //..................... FUNCIONES PARSER ............................//
    //...................................................................//
    
    
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "Cod_Empresa" {
            self.item.Codigo_Empresa = self.foundCharacters
        }
        if elementName == "Nombre_Empresa" {
            self.item.Nombre_Empresa = self.foundCharacters
        }
        
        if elementName == "Empresas" {
            let tempItem = Empresas();
            tempItem.Codigo_Empresa = self.item.Codigo_Empresa
            tempItem.Nombre_Empresa = self.item.Nombre_Empresa
            self.items.append(tempItem);
        }
        
        self.foundCharacters = ""
    }
    
    
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let value = string.trim();
        if( value != "\n"){
            self.foundCharacters += value;
        }else{
            self.foundCharacters = ""
        }
    }
    
    
}


