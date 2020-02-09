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
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var noBranchLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBranches()
        detailPopup.delegate = self
        // Do any additional setup after loading the view.
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.black]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributedStringColor)
        
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        // Do any additional setup after loading the view.
    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshControl.endRefreshing()
        fetchBranches()
    }
    
    //MARK: - API
    func fetchBranches(){
        GithubAPI.gitClient.getBranches(accesstoken: accessToken, ownerName: repo.owner?.login ?? "", repoName: repo.name ?? "") { (response, err) in
            self.branches = response ?? []
            DispatchQueue.main.async {
                if self.branches.count>0
                {
                    self.noBranchLbl.isHidden = true
                    self.activityLoader.stopAnimating()
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                }
                else{
                    self.noBranchLbl.isHidden = false
                }
            }
        }
    }
    func fetchLastCommit(branch: BranchResponse) {
        detailPopup.isHidden = false
        detailPopup.loader.startAnimating()
        GithubAPI.gitClient.getLastCommit(accesstoken: accessToken, url: branch.commit?.url ?? "") { (commit, err) in
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
    
    //MARK: - Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "PullSegue") {
            let destinationViewController = (segue.destination as! PullRequestVC)
            destinationViewController.accessToken = accessToken
            destinationViewController.repo = repo
            destinationViewController.branch = (sender as! BranchResponse)
        }
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
//MARK: - Tableview Datasource and Delegate
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
        let branch = self.branches[indexPath.row]
        self.performSegue(withIdentifier: "PullSegue", sender: branch)
        tableView.deselectRow(at: indexPath, animated: true)
        
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
