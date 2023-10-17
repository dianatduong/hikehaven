//
//  ViewController.swift
//  HikeHaven
//
//  Created by Diana Duong on 9/13/23.
//  Copyright © 2023 Diana Duong. All rights reserved.
//

import UIKit


class ViewController: UITableViewController {
    
    //API
    var unsplashArray: [UnSplashData] = []
    var parksArray: [ParkData] = []
    var weatherArray: [Periods] = []
        
    var headerView: HeaderView!
    var searchTerm: String = "Hiking"
    
    
    let stateCodes = ["CA", "NY", "TX", "FL", "IL", "WA"]
    var selectedStateCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the table view using the TableViewManager
        TableViewManager.configureTableView(for: tableView, withDelegate: self)
        
        setupHeader()
        
        //fetching API data
        fetchDataAPI()
        fetchImagesAPI()
        fetchWeatherAPI()
        
    }

    
    func setupHeader() {
        headerView = HeaderView()
        headerView.setTitle("Hiking Trails in")
        
        headerView.stateCodePicker.delegate = self // Set the delegate to ViewController
        headerView.stateCodePicker.dataSource = self // Set the data source to ViewController
        
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView?.frame.size.height = 65
    }
    
    
    //MARK: -  Fetching APIs
    
    func fetchImagesAPI() {
        APIManager.shared.fetchImagesAPI(searchTerm: searchTerm) { [weak self] unsplashArray in
            guard let self = self, let unsplashArray = unsplashArray else {
                return
            }
            self.unsplashArray = unsplashArray
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchDataAPI() {
        APIManager.shared.fetchDataAPI(searchTerm: searchTerm) { [weak self] parksArray in
            guard let self = self, let parksArray = parksArray else {
                return
            }
            self.parksArray = parksArray
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchWeatherAPI() {
        APIManager.shared.fetchWeatherAPI { [weak self] weatherArray in
            guard let self = self, let weatherArray = weatherArray else {
                return
            }
            self.weatherArray = weatherArray
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK: - TableViews
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return parksArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MainTableViewCell {
            
            let park = parksArray[indexPath.row]
            let unsplashData = unsplashArray[indexPath.row]
            
            cell.nameLabel.text = park.fullName
            
            //unwrap [Addresses]
            if let addresses = park.addresses, let firstAddress = addresses.first {
                let address = "\(firstAddress.line1)"
                let city = "\(firstAddress.city), "
                let state =  "\(firstAddress.stateCode) "
                let postalCode = "\(firstAddress.postalCode)"
                cell.addressLabel.text = address
                cell.cityLabel.text = city
                cell.stateLabel.text = state
                cell.postCodeLabel.text = postalCode
            }
            
            //unwrap urls: ImageURLS
            if let imageURLString = unsplashData.urls.regular,
                let imageURL = URL(string: imageURLString) {
                APIManager.shared.loadImage(from: imageURL) { image in
                    DispatchQueue.main.async {
                        cell.mainImageView.image = image
                    }
                }
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let park = parksArray[indexPath.row]
        let unsplashData = unsplashArray[indexPath.row]
        //let weather = weatherArray[indexPath.row]
        
        // Create instances of both view controllers
        let detailsVC = DetailsViewController()
        
        // Pass data to DetailsViewController
        detailsVC.selectedPark = park
        detailsVC.selectedUnsplashData = unsplashData
        // detailsVC.selectedWeatherData = weather
        
        // Push the DetailsViewController onto the navigation stack
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}


extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
 // MARK: UIPickerViewDataSource methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stateCodes.count
    }

    
    
    // MARK: UIPickerViewDelegate methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stateCodes[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStateCode = stateCodes[row]
    }
    
}

  /*
 
 UISearchBarDelegate
     var searchBar: UISearchBar = UISearchBar()
      var searchManager: SearchBarManager! // Add this property
    //let imageCache = NSCache<NSString, UIImage>()
 
 
 // Configure the search bar using the SearchBarManager
 //searchBar.delegate = self
 //searchManager = SearchBarManager(searchBar: searchBar)

*/
