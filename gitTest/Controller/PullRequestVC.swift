//
//  PullRequestVC.swift
//  gitTest
//
//  Created by Ankur Sehdev on 06/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import UIKit
import SafariServices

class PullRequestVC: UIViewController {
    @IBOutlet weak var noPRLbl: UILabel!
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    var pullRequest: [PullRequestResponse] = []
    var branch:BranchResponse!
    var accessToken:String!
    var repo:RepositoryResponse!
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var loaderView: Loader!
    
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPullRequests()
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.black]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributedStringColor)

        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        // Do any additional setup after loading the view.
    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshControl.endRefreshing()
        fetchPullRequests()
    }
    
    //MARK: - API
    func fetchPullRequests(){
        GithubAPI.gitClient.getPullRequests(accesstoken: accessToken, ownerName: repo.owner?.login ?? "", repoName: repo.name ?? "", branch: branch.name ?? "") { (response, err) in
            self.pullRequest = response ?? []
            DispatchQueue.main.async {
                self.loaderView.isHidden = true
                self.activityLoader.stopAnimating()
                if(self.pullRequest.count>0){
                    self.noPRLbl.isHidden = true
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                }
                else{
                    self.noPRLbl.isHidden = false
                }
            }
        }
    }
    
    func rejectPR(_ pullReq: PullRequestResponse){
        loaderView.isHidden = false
        self.loaderView.loaderMessage(message: "Updating...")
        GithubAPI.gitClient.rejectPRStatus(accesstoken: accessToken, ownerName: repo.owner?.login ?? "", repoName: repo.name ?? "" , prNumber: pullReq.number ?? 0) { (res, err) in
            DispatchQueue.main.async {
                self.loaderView.isHidden = true
                self.rejectPRAPIAlert()
            }
        }
    }
    
    func approvePR(_ pullReq: PullRequestResponse){
        loaderView.isHidden = false
        self.loaderView.loaderMessage(message: "Updating...")
        self.tableView.isHidden = true
        self.activityLoader.startAnimating()
        GithubAPI.gitClient.updatePRStatus(accesstoken: accessToken, ownerName: repo.owner?.login ?? "", repoName: repo.name!, prNumber: pullReq.number ?? 0) { (res, err) in
            self.fetchPullRequests()
        }
    }
    
    func rejectPRAPIAlert(){
        UIViewController.displayAlertController(title: "Note", message: "Reject API has been called by git but PR status is not updated on web interface as this API is still under preview phase. Please visit the following URL to read more about it.", buttonTitle: ["No Thanks", "Read More"]){ (index) in
            if index == 1{
                self.openGitReadMoreLink()
            }
        }
    }
    
    func openGitReadMoreLink(){
        let safariVC = SFSafariViewController(url: URL(string: "https://developer.github.com/v3/pulls/#update-a-pull-request")! as URL)
        safariVC.modalPresentationStyle = .automatic
        self.present(safariVC, animated: true, completion: nil)
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
extension PullRequestVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pullRequest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PullRequestCell") as! PullRequestCell
        cell.isUserInteractionEnabled = false
        cell.approvedIcon.image = #imageLiteral(resourceName: "tick")
        let pullReq = self.pullRequest[indexPath.row]
        cell.prLbl.text = pullReq.title
        
        let body = pullReq.body ?? "" == "" ? "NA" : pullReq.body ?? ""
        
        cell.numberLbl.text = "#\(String(describing: pullReq.number!))"
        cell.bodyLbl.text = "Description: \(body)"

        if(!(pullReq.mergedAt ?? "").isEmpty){
            cell.statusLbl.text = "Status: Approved"
        }
        else{
            if (pullReq.state ?? "" == "open"){
                cell.statusLbl.text = "Status: Pending"
                cell.isUserInteractionEnabled = true
                cell.approvedIcon.image = #imageLiteral(resourceName: "warning")
            }
            else{
                cell.statusLbl.text = "Status: Rejected"
                cell.approvedIcon.image = #imageLiteral(resourceName: "cross")
            }
        }
        
//        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pullReq = self.pullRequest[indexPath.row]

        UIAlertController.displayActionsheet(viewController: self, title: nil, message: "Choose Option", buttonTitle: ["Approve", "Reject"]) { (index) in
            if index == 0{
                self.approvePR(pullReq)
            }
            else{
                self.rejectPR(pullReq)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
//MARK: - UIViewController Extensions
extension UIViewController {
    static var topMostViewController : UIViewController {
        get {
            if let window = UIApplication.shared.keyWindow {
                return UIViewController.topViewController(rootViewController: window.rootViewController!)
            }
            else {
                return UIViewController()
            }
        }
    }
    
    fileprivate static func topViewController(rootViewController: UIViewController) -> UIViewController {
        guard rootViewController.presentedViewController != nil else {
            if rootViewController is UITabBarController {
                let tabbarVC = rootViewController as! UITabBarController
                let selectedViewController = tabbarVC.selectedViewController
                return UIViewController.topViewController(rootViewController: selectedViewController!)
            }
                
            else if rootViewController is UINavigationController {
                let navVC = rootViewController as! UINavigationController
                return UIViewController.topViewController(rootViewController: navVC.viewControllers.last!)
            }
            
            return rootViewController
        }
        
        return topViewController(rootViewController: rootViewController.presentedViewController!)
    }
    internal class func displayActionsheet (viewController: UIViewController = UIViewController.topMostViewController, title: String? = nil, message: String?, buttonTitle arrbtn:[String], CompletionHandler comp:((_ index: Int) -> Void)? = nil) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for strTitle in arrbtn {
            let alertAction = UIAlertAction(title: strTitle, style: UIAlertAction.Style.default, handler: { (action) in
                if let completion = comp, let title = action.title, let index = arrbtn.firstIndex(of: title) {
                    completion(index)
                }
            })
            alertVC.addAction(alertAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertVC.addAction(cancelAction)
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    internal class func displayAlertController (viewController: UIViewController = UIViewController.topMostViewController, title: String? = nil, message: String?, buttonTitle arrbtn:[String], CompletionHandler comp:((_ index: Int) -> Void)? = nil) {
                
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        for i in 1..<arrbtn.count {
            let alertAction = UIAlertAction(title: arrbtn[i], style: UIAlertAction.Style.default, handler: { (action) in
                if let completion = comp, let title = action.title, let index = arrbtn.firstIndex(of: title) {
                    completion(index)
                }
            })
            alertVC.addAction(alertAction)
        }
        let cancelAction = UIAlertAction(title: arrbtn[0], style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertVC.addAction(cancelAction)
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction internal func unwindToViewController (_ segue: UIStoryboardSegue){}

}
