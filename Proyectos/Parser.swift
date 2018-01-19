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
    func parseDatos(URL_ : String){
        let url = URL(string: URL_)
        elementos = [:]
        for element in mapeo{
            elementos[element] = []
        }
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            let parser = XMLParser(data: data!)
            parser.delegate = self
            parser.parse()
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
