//
//  TravelViewController.swift
//  Travelogue
//
//  Created by Alex Davis on 12/4/19.
//  Copyright © 2019 Alex Davis. All rights reserved.
//

import UIKit
import CoreData

class TravelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var logs = [Log]()
    var oneWarning = 0
    var dateFormatter = DateFormatter()
    @IBOutlet weak var logsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchLogs()
        logsTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell", for: indexPath)
        
        let log = logs[indexPath.row]
        cell.textLabel?.text = log.title
        if let addDate = log.addDate {
            cell.detailTextLabel?.text = dateFormatter.string(from: addDate)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            self.deleteLog(indexPath: indexPath)
        }
        return [deleteAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? TravelDetailTableViewController else {
            return
        }
        
        if let segueIdentifier = segue.identifier, segueIdentifier == "log", let indexPathForSelectedRow = logsTableView.indexPathForSelectedRow {
            destination.log = logs[indexPathForSelectedRow.row]
        }
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteLog(indexPath: IndexPath) {
        let log = logs[indexPath.row]
        
        if let managedObjectContext = log.managedObjectContext {
            managedObjectContext.delete(log)
            
            do {
                if oneWarning == 0 {
                    alertNotifyUser(message: "Warning: Deletions are permanent.")
                    oneWarning = 1
                } else {
               try managedObjectContext.save()
               self.logs.remove(at: indexPath.row)
               logsTableView.reloadData()
                }
            } catch {
                alertNotifyUser(message: "Delete failed.")
                logsTableView.reloadData()
            }
        }
    }
    
    func fetchLogs() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            logs = [Log]()
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rawAddDate", ascending: true)]
        
        do {
            logs = try managedContext.fetch(fetchRequest)
        } catch {
            alertNotifyUser(message: "Fetch for logs failed.")
        }
    }
}
