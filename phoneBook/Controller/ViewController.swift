//
//  ViewController.swift
//  phoneBook
//
//  Created by 백시훈 on 7/12/24.
//

import UIKit
import SnapKit
import CoreData
import Alamofire
class ViewController: UIViewController {
    var container: NSPersistentContainer!
    var phoneBookData: [PhoneBookModel] = []
    var mainView: MainView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView = MainView(frame: self.view.frame)
        self.view = mainView
        setAction()
        setTableView()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        
    }
    override func viewWillAppear(_ animated: Bool) {
        readAllData()
        mainView.tableView.reloadData()
    }
    func setAction(){
        mainView.button.addTarget(self, action: #selector(didButtonTapped), for: .touchDown)
    }
    func setTableView(){
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.id)
    }
    func readAllData(){
        phoneBookData.removeAll()
        do{
            let phoneBooks = try self.container.viewContext.fetch(PhoneBook.fetchRequest())
            for phoneBook in phoneBooks as [NSManagedObject] {
                if let name = phoneBook.value(forKey: PhoneBook.Key.name) as? String,
                   let number = phoneBook.value(forKey: PhoneBook.Key.number) as? String,
                   let imageUrl = phoneBook.value(forKey: PhoneBook.Key.imageUrl) as? NSURL
                {
                    let phoneBookModel = PhoneBookModel(name: name, number: number, imageUrl: imageUrl.absoluteString!)
                    phoneBookData.append(phoneBookModel)
                    phoneBookData.sort { $0.name < $1.name }
                }
            }
        }catch{
            print("데이터 읽기 실패")
        }
    }
    
    
    
    @objc func didButtonTapped(){
        let phoneBookViewController = PhoneBookViewController()
        phoneBookViewController.isCell = false
        navigationController?.pushViewController(phoneBookViewController, animated: true)
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        phoneBookData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.id, for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }
        cell.nameLabel.text = phoneBookData[indexPath.row].name
        cell.numberLabel.text = phoneBookData[indexPath.row].number
        AF.request(phoneBookData[indexPath.row].imageUrl).responseData { response in
            if let data = response.data, let image = UIImage(data: data){
                DispatchQueue.main.async {
                    cell.customImageView.image = image
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = phoneBookData[indexPath.row]
        let phoneBookViewController = PhoneBookViewController()
        phoneBookViewController.phoneBookModel = model
        phoneBookViewController.isCell = true
        navigationController?.pushViewController(phoneBookViewController, animated: true)
    }
}
