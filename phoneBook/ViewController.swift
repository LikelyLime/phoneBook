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
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("추가", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        return button
    }()
    private let label: UILabel = {
        let label = UILabel()
        label.text = "친구 목록"
        label.textColor = .black
        label.backgroundColor = .white
        label.font = .boldSystemFont(ofSize: 23)
        return label
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.id)
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        
    }
    override func viewWillAppear(_ animated: Bool) {
        readAllData()
        tableView.reloadData()
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
    
    private func configureUI(){
        button.addTarget(self, action: #selector(didButtonTapped), for: .touchDown)
        [button, label, tableView].forEach{ view.addSubview($0) }
        button.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.right.equalTo(view.safeAreaLayoutGuide)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        label.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
    
    @objc func didButtonTapped(){
        let phoneBookViewController = PhoneBookViewController()
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
    
}
