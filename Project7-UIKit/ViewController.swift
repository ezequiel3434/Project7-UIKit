//
//  ViewController.swift
//  Project7-UIKit
//
//  Created by Ezequiel Parada Beltran on 18/08/2020.
//  Copyright © 2020 Ezequiel Parada. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for news..."
        return searchBar
    }()
    
    
    var petitionsResult = [Petition]()
    
    var petitions = [Petition]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let credits = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showCredits))
        let urlString: String
        navigationItem.rightBarButtonItem = credits
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        searchBar.delegate = self
        // searchBar.becomeFirstResponder()
        
        if navigationController?.tabBarItem.tag == 0 {
            
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            print("tops")
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        navigationController?.tabBarController?.delegate = self
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return}
        }
        
        showError()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.text = nil
        //            searchBar.resignFirstResponder()
        petitionsResult = petitions
        tableView.reloadData()
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "This data comes from the We The People API of the Whitehouse.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json){
            petitions = jsonPetitions.results
            petitionsResult = petitions
            tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitionsResult.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitionsResult[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitionsResult[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        petitionsResult.removeAll()
        
        filterUsers(with: text)
    }
    
    
    
    func filterUsers(with term: String) {
        
        // update the UI: either show results or show no results label
        
        
        let results: [Petition] = petitions.filter({
            
            let title = $0.title.lowercased()
            
            
            
            
            return title.contains(term.lowercased())
        }).compactMap({
            let title = $0.title
            let body = $0.body
            let signatureCount = $0.signatureCount
            return Petition(title: title, body: body, signatureCount: signatureCount)
        })
        
        self.petitionsResult = results
        
        tableView.reloadData()
        //updateUI()
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            petitionsResult = petitions
            tableView.reloadData()
        }
    }
}

extension ViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 {
            print(viewController)
            searchBar.text = nil
            //            searchBar.resignFirstResponder()
            petitionsResult = petitions
            tableView.reloadData()
            
        }else {
            print(viewController)
            
        }
    }
}
