//
//  BranchVC.swift
//  gitTest
//
//  Created by Ankur Sehdev on 05/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import UIKit

class BranchVC: UIViewController {
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    @IBOutlet weak var detailPopup: PopupView!
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    var branches: [BranchResponse] = []
    var repo:RepositoryResponse!
    var accessToken:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBranches()
        detailPopup.delegate = self
        // Do any additional setup after loading the view.
    }
    func fetchBranches(){
        GithubLoginAPI().getBranches(accesstoken: accessToken, ownerName: repo.owner?.login ?? "", repoName: repo.name ?? "") { (response, err) in
            self.branches = response ?? []
            DispatchQueue.main.async {
                self.activityLoader.stopAnimating()
                self.tableView.reloadData()
                self.tableView.isHidden = false
            }
        }
    }
    func fetchLastCommit(branch: BranchResponse) {
        detailPopup.isHidden = false
        detailPopup.loader.startAnimating()
        GithubLoginAPI().getLastCommit(accesstoken: accessToken, url: branch.commit?.url ?? "") { (commit, err) in
            DispatchQueue.main.async {
                self.updatePopup(commit: commit!)
            }
        }
    }
    
    func updatePopup(commit : CommitResponse){
        detailPopup.loader.stopAnimating()
        detailPopup.showData()
        detailPopup.messageLbl.text = commit.message
        detailPopup.shaLbl.text = commit.sha
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension BranchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.branches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BranchCell") as! BranchCell
        let branch = self.branches[indexPath.row]
        cell.branchName.text = branch.name
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let branch = self.branches[indexPath.row]
//        self.performSegue(withIdentifier: "BranchSegue", sender: BranchSegue)

    }
}
extension BranchVC: BranchCellDelegate {
    func infoButtonPressed(_ cell: BranchCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let branch = self.branches[indexPath!.row]
        self.fetchLastCommit(branch: branch)
    }
}
extension BranchVC: PopUpViewDelegate {
    func closeButtonPressed(_ sender: Any) {
        detailPopup.isHidden = true
        detailPopup.hideData()
    }
}
