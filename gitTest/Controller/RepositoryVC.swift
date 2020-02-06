//
//  ViewController.swift
//  gitTest
//
//  Created by Ankur Sehdev on 04/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import UIKit
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
class RepositoryVC: UIViewController {
    var token: String! = nil
    var repos: [RepositoryResponse] = []

   @IBOutlet var tableView: UITableView! {
         didSet {
             tableView.delegate = self
             tableView.dataSource = self
         }
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
//        self.webView.isHidden = true
    }

    @IBAction func loginAction(_ sender: Any) {
        let loginWeb = self.storyboard?.instantiateViewController(withIdentifier: "LoginWebVC") as! LoginWebVC
        loginWeb.login(completion: { accessToken in
            self.token = accessToken
            self.fetchRepos(accessToken: self.token)
        }, error: { error in
            print(error.localizedDescription)
        })
        self.present(loginWeb, animated: true, completion: nil)
    }
    
    func fetchRepos(accessToken: String){
        GithubLoginAPI().getRepos(accesstoken: accessToken) { (response, err) in
            self.repos = response ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.isHidden = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "BranchSegue") {
            let destinationViewController = (segue.destination as! BranchVC)
            destinationViewController.accessToken = token
            destinationViewController.repo = sender as! RepositoryResponse
        }
    }

}

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

//        guard let path = file.path else { return }
//        
//        if file.type == "file" {
//            let storyboard = UIStoryboard(name: "RepositoryFileVC", bundle: nil)
//            let repositoryFileVC = storyboard.instantiateViewController(withIdentifier: "RepositoryFileVC") as! RepositoryFileVC
//            repositoryFileVC.path = path
//            repositoryFileVC.token = token
//            self.navigationController?.pushViewController(repositoryFileVC, animated: true)
//        } else if file.type == "dir" {
//            let storyboard = UIStoryboard(name: "RepositoryVC", bundle: nil)
//            let repositoryVC = storyboard.instantiateViewController(withIdentifier: "RepositoryVC") as! RepositoryVC
//            repositoryVC.path = path
//            repositoryVC.token = token
//            self.navigationController?.pushViewController(repositoryVC, animated: true)
//        }
    }
}
