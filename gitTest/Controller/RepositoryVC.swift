//
//  ViewController.swift
//  gitTest
//
//  Created by Ankur Sehdev on 04/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import UIKit
import WebKit

public enum Scopes : String {
    case user = "user"
    case userEmail = "user:email"
    case userFollow = "user:follow"
    case publicRepo = "public_repo"
    case private_repo = "private_repo"
    case repo = "repo"
    case repoDeployment = "repo_deployment"
    case repoStatus = "repo:status"
    case deleteRepo = "delete_repo"
    case notifications = "notifications"
    case gist = "gist"
    case readRepoHook = "read:repo_hook"
    case writeRepoHook = "write:repo_hook"
    case adminRepoHook = "admin:repo_hook"
    case adminOrgHook = "admin:org_hook"
    case readOrg = "read:org"
    case writeOrg = "write:org"
    case adminOrg = "admin:org"
    case readPublicKey = "read:public_key"
    case writePublicKey = "write:public_key"
    case adminPublicKey = "admin:public_key"
    case readGPGKey = "read:gpg_key"
    case writeGPGKey = "write:gpg_key"
    case adminGPGKey = "admin:gpg_key"
}
@available(iOS 11.0, *)
class RepositoryVC: UIViewController {
    var token: String! = UserDefaults.standard.value(forKey: "gitToken") as? String ?? ""
    var repos: [RepositoryResponse] = []
    
    @IBOutlet weak var loaderView: Loader!
    @IBOutlet weak var logoutItem: UIBarButtonItem!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var logoutBarBtn: UIButton!
    @IBOutlet weak var noRepoLbl: UILabel!
    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var gitLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if !token.isEmpty {
            loaderView.isHidden = false
            self.loaderView.loaderMessage(message: "Fetching Repo...")
            fetchRepos(accessToken: token)
            updateLogoutBtn()
        }
        else{
            loginBtn.isHidden = false
            loaderView.isHidden = true
        }
        
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.black]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributedStringColor)
        
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - API
    func fetchRepos(accessToken: String){
        GithubAPI.gitClient.getRepos(accesstoken: accessToken) { (response, err) in
            if (err != nil){
                DispatchQueue.main.async {
                    self.loaderView.isHidden = true
                    self.noRepoLbl.isHidden = false
                    self.noRepoLbl.text = err?.localizedDescription
                    self.gitLogo.isHidden = true
                    self.welcomeLbl.isHidden = true
                    self.tableView.isHidden = true
                }
            }else{
                self.repos = response ?? []
                DispatchQueue.main.async {
                    if(self.repos.count > 0){
                        self.noRepoLbl.isHidden = true
                        if self.loaderView.activityLoader.isAnimating{
                            self.loaderView.isHidden = true
                        }
                        self.tableView.reloadData()
                        self.tableView.isHidden = false
                    }
                    else{
                        self.noRepoLbl.isHidden = false
                        self.noRepoLbl.text = "No Repository Found"
                    }
                }
            }
        }
    }
    
    //MARK: - Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "BranchSegue") {
            let destinationViewController = (segue.destination as! BranchVC)
            destinationViewController.accessToken = token
            destinationViewController.repo = (sender as! RepositoryResponse)
        }
    }
    
    //MARK: - Button Actions
    @IBAction func loginAction(_ sender: Any) {
        let loginWeb = self.storyboard?.instantiateViewController(withIdentifier: "LoginWebVC") as! LoginWebVC
        loginWeb.login(completion: { accessToken in
            self.token = accessToken
            UserDefaults.standard.setValue(accessToken, forKey: "gitToken")
            self.fetchRepos(accessToken: self.token)
            self.updateLogoutBtn()
            
        }, error: { error in
            print(error.localizedDescription)
        })
        self.present(loginWeb, animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        UIViewController.displayAlertController(title: "Logout", message: "Are you sure you want to logout?", buttonTitle: ["No", "Yes"]){ (index) in
            if index == 1{
                self.initiateLogout()
            }
        }
    }
    
    //MARK: - Logical Methods
    func initiateLogout(){
        removeCookies()
        clearData()
        tableView.isHidden = true
        self.loginBtn.isHidden = false
        self.gitLogo.isHidden = false
        self.welcomeLbl.isHidden = false
        updateLogoutBtn()
    }
    
    func clearData(){
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey:"gitToken")
        repos.removeAll()
        self.token = ""
    }
    
    func removeCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    func updateLogoutBtn() {
        logoutBarBtn.isHidden = !logoutBarBtn.isHidden
        self.title = logoutBarBtn.isHidden ? "GitHub" : "Repositories"
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshControl.endRefreshing()
        fetchRepos(accessToken: token)
    }
}
//MARK: - Tableview Datasource and Delegate
@available(iOS 11.0, *)
extension RepositoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell") as! RepositoryCell
        let repo = self.repos[indexPath.row]
        cell.repoName.text = repo.fullName
        cell.repoTypeIcon.image = repo.privateField ?? false ? #imageLiteral(resourceName: "lock") : #imageLiteral(resourceName: "open")
        cell.forkIcon.isHidden = repo.fork ?? false ? false : true
        cell.userImg.load(url: repo.owner?.avatarUrl ?? "")
        //        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repo = self.repos[indexPath.row]
        self.performSegue(withIdentifier: "BranchSegue", sender: repo)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
