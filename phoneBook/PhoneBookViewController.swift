//
//  PhoneBookViewController.swift
//  phoneBook
//
//  Created by 백시훈 on 7/12/24.
//

import Foundation
import UIKit
import SnapKit
import Alamofire
import CoreData

class PhoneBookViewController: UIViewController{
    
    var urlData = ""
    var container: NSPersistentContainer!
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 100
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let createImageButton: UIButton = {
       let button = UIButton()
        button.setTitle("랜덤 이미지 생성", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(createImage), for: .touchDown)
        return button
    }()
    
    private let nameTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 16.0)
        textView.text = ""
        textView.textColor = .black
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 2.0
        textView.layer.borderColor = UIColor.systemMint.cgColor
        return textView
    }()
    private let numberTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 16.0)
        textView.text = ""
        textView.textColor = .black
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 2.0
        textView.layer.borderColor = UIColor.systemMint.cgColor
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
    }
    
    private func configureUI(){
        let button = UIBarButtonItem(title: "적용", style: .plain, target: self, action: #selector(buttonTap))
        navigationItem.title = "연락처 추가"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItems = [button]
        [imageView, createImageButton, nameTextView, numberTextView].forEach {
            view.addSubview($0)
        }
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.width.equalTo(200)
            $0.height.equalTo(200)
        }
        createImageButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.width.equalTo(createImageButton.titleLabel!.intrinsicContentSize.width + 20)
            $0.height.equalTo(50)
        }
        nameTextView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(createImageButton.snp.bottom).offset(30)
            $0.height.equalTo(40)
        }
        numberTextView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(nameTextView.snp.bottom).offset(10)
            $0.height.equalTo(40)
        }
    }
    @objc func buttonTap(){
        print(urlData)
        validData()
        createData()
        returnPage()
    }
    
    public func createData(){
        guard let entity = NSEntityDescription.entity(forEntityName: PhoneBook.className, in: self.container.viewContext) else { return }
        let newPhoneBook = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
        newPhoneBook.setValue(nameTextView.text, forKey: "name")
        newPhoneBook.setValue(numberTextView.text, forKey: "number")
        print("urlData : \(urlData)")
        if let imageUrl = URL(string: urlData) {
            newPhoneBook.setValue(imageUrl as NSURL, forKey: "imageUrl")
        }
        do{
            try self.container.viewContext.save()
        }catch{
            print("저장 실패")
        }
    }
    
    private func returnPage(){
        navigationController?.popViewController(animated: true)
    }
    
    private func validData(){
        if nameTextView.text.isEmpty{
            showAlert(content: "이름")
            return
        }
        if urlData.isEmpty{
            showAlert(content: "이미지")
            return
        }
        if numberTextView.text.isEmpty{
            showAlert(content: "전화번호")
            return
        }
    }
    
    
    private func showAlert(content: String){
        let alert = UIAlertController(title: "확인", message: "\(content)란(이)가 비어있습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func createImage(){
        let randomNum = Int.random(in: 1...1000)
        let urlComponents = URLComponents(string: "https://pokeapi.co/api/v2/pokemon/\(randomNum)")
        guard let url = urlComponents?.url else {
            print("잘못된 URL 입니다.")
            return
        }
        fetchDataByAlamofire(url: url){ [weak self] (result: Result<NewImageResponse, AFError>) in
            switch result {
                case .success(let result):
                    guard let imageUrl = URL(string: result.sprites.frontDefault)else{
                        return
                    }
                    self!.urlData = String(result.sprites.frontDefault)
                    AF.request(imageUrl).responseData { response in
                        if let data = response.data, let image = UIImage(data: data){
                            DispatchQueue.main.async {
                                
                                self?.imageView.image = image
                            }
                        }
                    }
                case .failure(let error):
                    print("데이터 로드 실패: \(error)")
                    
            }
        }
    }
    
    private func fetchDataByAlamofire<T: Decodable>(url: URL, completion: @escaping (Result<T, AFError>) -> Void) {
        AF.request(url).responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
}
