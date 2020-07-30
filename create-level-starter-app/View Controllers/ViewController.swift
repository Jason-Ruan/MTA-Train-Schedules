//
//  ViewController.swift
//  create-level-starter-app
//
//  Created by Jason Ruan on 7/20/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet weak var stationTableView: UITableView!
    
    
    //MARK: - Subviews
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Level Code Challenge"
        //        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.font = UIFont(name: "Consolas", size: 30)
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search by station"
        sb.delegate = self
        return sb
    }()
    
    private lazy var arrivalTimesTableView: UITableView = {
        let tv = UITableView(frame: CGRect(x: self.stationTableView.frame.minX + 20, y: self.stationTableView.frame.minY + 20, width: self.stationTableView.frame.width - 40, height: self.stationTableView.frame.height - 40), style: .grouped)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "arrivalTimesCell")
        tv.layer.borderWidth = 5
        tv.layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        tv.layer.cornerRadius = 25
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    private lazy var closeButton: UIButton = {
        let closeButton = UIButton(type: .close)
        closeButton.addTarget(self, action: #selector(self.dismissArrivalTimesTableView), for: .touchUpInside)
        closeButton.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        return closeButton
    }()
    
    private lazy var backgroundView: UIView = {
        let backgroundView: UIView = UIView(frame: self.stationTableView.frame)
        backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        return backgroundView
    }()
    
    //MARK: - Private Properties
    private var totalStations: [Station] = [] {
        didSet {
            filteredStations = totalStations
        }
    }
    
    private var filteredStations: [Station] = [] {
        didSet {
            stationTableView.reloadData()
        }
    }
    
    private var selectedStation: Station? = nil {
        didSet {
            guard let selectedStation = self.selectedStation else { return }
            MTA_API_Client.manager.getArrivalTimesForStation(withID: selectedStation.id) { (result) in
                switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let arrivalTimes):
                        self.arrivalTimesOfSelectedStation = ["N" : arrivalTimes.N, "S": arrivalTimes.S]
                }
            }
        }
    }
    
    private var arrivalTimesOfSelectedStation: [String : [Route_Time]] = [:] {
        didSet {
            arrivalTimesTableView.reloadData()
        }
    }
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        constrainSubviews()
        
        loadStations()
        stationTableView.dataSource = self
        stationTableView.delegate = self
        stationTableView.register(UITableViewCell.self, forCellReuseIdentifier: "stationCell")
    }
    
    
    //MARK: - Private Functions
    private func loadStations() {
        guard let url = URL(string: "https://raw.githubusercontent.com/jonthornton/MTAPI/master/data/stations.json") else {
            return
            
        }
        MTA_API_Client.manager.getStations(url: url) { (result) in
            switch result {
                case .success(let stations):
                    self.totalStations = stations
                case .failure(let error):
                    print("Could not load stations, error: \(error)")
            }
        }
    }
    
    private func formatTimeString(timeStr: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: timeStr)
        dateFormatter.dateFormat = "MM/dd/yyyy - hh:mm aa"
        return dateFormatter.string(from: date ?? Date())
    }
    
    @objc private func dismissArrivalTimesTableView() {
        backgroundView.removeFromSuperview()
        arrivalTimesTableView.removeFromSuperview()
        closeButton.removeFromSuperview()
    }
    
    
    //MARK: - TableView Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == arrivalTimesTableView {
            return 3
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == stationTableView {
            return filteredStations.count
        } else if tableView == arrivalTimesTableView {
            switch section {
                case 1:
                    guard let northBoundTimes = arrivalTimesOfSelectedStation["N"] else { return 0 }
                    return northBoundTimes.count
                case 2:
                    guard let southBoundTimes = arrivalTimesOfSelectedStation["S"] else { return 0 }
                    return southBoundTimes.count
                default:
                    return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == stationTableView {
            return "MTA Stations"
        } else if tableView == arrivalTimesTableView, let selectedStation = self.selectedStation {
            switch section {
                case 0:
                    return "Arrival Times for:\n\(selectedStation.name)"
                case 1:
                    return "Northbound Times and Routes"
                case 2:
                    return "Southbound Times and Routes"
                default:
                    return nil
            }
        }
        return "MTA Stations"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == stationTableView {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "stationCell")
            cell.textLabel?.text = filteredStations[indexPath.row].name
            cell.detailTextLabel?.text = filteredStations[indexPath.row].id
            return cell
        } else if tableView == arrivalTimesTableView {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "arrivalTimesCell")
            switch indexPath.section {
                case 1:
                    cell.textLabel?.text = arrivalTimesOfSelectedStation["N"]![indexPath.row].route
                    cell.detailTextLabel?.text = formatTimeString(timeStr: arrivalTimesOfSelectedStation["N"]![indexPath.row].time)
                    return cell
                case 2:
                    cell.textLabel?.text = arrivalTimesOfSelectedStation["S"]![indexPath.row].route
                    cell.detailTextLabel?.text = formatTimeString(timeStr: arrivalTimesOfSelectedStation["S"]![indexPath.row].time)
                    return cell
                default:
                    return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 15
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == stationTableView {
            self.selectedStation = filteredStations[indexPath.row]
            view.addSubview(backgroundView)
            view.addSubview(arrivalTimesTableView)
            view.addSubview(closeButton)
            constrainArrivalTimesTableView()
            constrainCloseButton()
        }
    }
    
}

//MARK: - SearchBar Functions
extension ViewController {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard searchBar.text != ""  else {
            searchBar.resignFirstResponder()
            return
        }
        
        filteredStations = totalStations.filter { $0.name.contains(searchBar.text!.capitalized) }
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        filteredStations = totalStations
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
}

//MARK: - Constraints
extension ViewController {
    private func setupSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
    }
    
    private func constrainSubviews() {
        constrainTitleLabel()
        constrainSearchBar()
        constrainWStationTableView()
    }
    
    private func constrainTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func constrainSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            searchBar.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func constrainWStationTableView() {
        stationTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stationTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
            stationTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stationTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stationTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func constrainArrivalTimesTableView() {
        arrivalTimesTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arrivalTimesTableView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            arrivalTimesTableView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            arrivalTimesTableView.heightAnchor.constraint(equalToConstant: self.stationTableView.frame.height * 4 / 5),
            arrivalTimesTableView.widthAnchor.constraint(equalToConstant: self.stationTableView.frame.width * 4 / 5)
        ])
    }
    
    private func constrainCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: arrivalTimesTableView.topAnchor),
            closeButton.centerXAnchor.constraint(equalTo: arrivalTimesTableView.trailingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 50),
            closeButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        closeButton.layer.cornerRadius = closeButton.frame.height / 2
    }
    
    
}
