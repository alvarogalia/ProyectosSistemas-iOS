//
//  ViewController.swift
//  LogoEmpresa
//
//  Created by Desarrollo on 28-12-17.
//  Copyright © 2017 Cristopher Neira. All rights reserved.
//

import UIKit


//------------------------OBJETO EMPRESA------------------------//

class Empresas {
    var Nombre_Empresa = ""
    var Codigo_Empresa = ""
}
class EmpresasViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, XMLParserDelegate {
    
    var items = [Empresas]();
    var item = Empresas();
    var foundCharacters = "";
    let userDefaults = UserDefaults.standard
    var SELECTED_EMPRESA = ""
    var SELECTED_NombreEmpresa = ""
    @IBOutlet weak var Mycollection: EmpresasCollectionViewCell!
    
    @IBOutlet weak var Collection: UICollectionView!
    
    //------------------------------------------------------------------------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Collection.delegate = self
        self.Collection.dataSource = self
    }
    
    //------------------------------------------------------------------------------------------//
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //------------------------------------------------------------------------------------------//
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    //------------------------------------------------------------------------------------------//
    //Funcion que permite ingresar los datos (Nombre empresa, Codigo y su Imagen) a las celdas
    //------------------------------------------------------------------------------------------//
    
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
    
    //------------------------------------------------------------------------------------------//
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.SELECTED_EMPRESA = items[indexPath.row].Codigo_Empresa
        userDefaults.set(self.SELECTED_EMPRESA, forKey: "Cod_Empresa")
        
        self.SELECTED_NombreEmpresa = items[indexPath.row].Nombre_Empresa
        userDefaults.set(self.SELECTED_NombreEmpresa, forKey: "NombreEmpresa")
        
        performSegue(withIdentifier: "empresaSeleccionadaSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
    
    //------------------------------------------------------------------------------------------//
    //Funcion que permite comunicarse con el servicio
    //------------------------------------------------------------------------------------------//
    
    
    
    //------------------------------------------------------------------------------------------//
    //Funcion que permite comunicarse con el servicio para poder obtener datos
    //------------------------------------------------------------------------------------------//
    
    
    override func viewWillAppear(_ animated: Bool) {
        let url = URL(string: "http://200.111.46.182/WS_MovilProyecto/MovilProyecto.asmx/getListadoEmpresas")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            let parser = XMLParser(data: data!)
            parser.delegate = (self as XMLParserDelegate)
            parser.parse()
            
            DispatchQueue.main.async {
                self.Collection.reloadData()
            }
        }
        
        if(items.count == 0){
            task.resume()
        }
    }
    
    //------------------------------------------------------------------------------------------//
    //Funcion que permite guardar en un objeto los datos encontrados
    //------------------------------------------------------------------------------------------//
    
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
    
    //------------------------------------------------------------------------------------------//
    //Funcion que permite retornar String encontrado sin espacios ni saltos de lineas
    //------------------------------------------------------------------------------------------//
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let value = string.trim();
        if( value != "\n"){
            self.foundCharacters += value;
        }else{
            self.foundCharacters = ""
        }
    }
    
    
}


