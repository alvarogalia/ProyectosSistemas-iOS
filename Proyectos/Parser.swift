//
//  XMLParser.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 17-01-18.
//  Copyright © 2018 SistemasSA. All rights reserved.
//

import UIKit

class Parser: XMLParser, XMLParserDelegate {
    
    var mapeo : [String] = []
    var elementos : [String:[String]] = [:]
    private var foundCharacters = ""
    
    func parseDatos(URL_ : String, Vista: UIViewController){
        let url = URL(string: URL_)
        elementos = [:]
        for element in mapeo{
            elementos[element] = []
        }
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            if(data != nil){
                let parser = XMLParser(data: data!)
                parser.delegate = self
                parser.parse()
                
                DispatchQueue.main.async {
                    if let vista = Vista as? BuscarProyectosTableViewController{
                        UIView.animate(withDuration: 0.2, animations: {
                            vista.effectView.alpha = 0.0
                        }, completion:{ (finished: Bool) in
                            vista.effectView.removeFromSuperview()
                            vista.view.isUserInteractionEnabled = true
                        })
                    }
                }
            }
         
            else{
                DispatchQueue.main.async {
                    let vista = Vista as? BuscarProyectosTableViewController
                    let alert = UIAlertController(title: "Error", message: "Problemas de conexión", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Reintentar", style: UIAlertActionStyle.default, handler: nil))
                    vista?.effectView.removeFromSuperview()
                    vista?.view.isUserInteractionEnabled = true
                }
            }
        }
        task.resume()
    }
    
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if self.mapeo.contains(elementName) {
            if(!(elementos[elementName]?.contains(self.foundCharacters))!){
                elementos[elementName]?.append(self.foundCharacters)
            }
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
    
    func parserDidEndDocument(_ parser: XMLParser) {
        for item in elementos{
            elementos[item.key] = item.value.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        }
    }
}
