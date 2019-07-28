//
//  TripEntriesTableViewController.swift
//  Travelogue
//
//  Created by 刘洋 on 7/23/19.
//  Copyright © 2019 Yang Liu. All rights reserved.
//

import UIKit
import CoreData

class TripEntriesTableViewController: UITableViewController {
    
    var trip: Trip? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return trip?.entries?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Trip Entry Cell", for: indexPath)
        let entry = trip?.entries?.allObjects[indexPath.row]
        configureCell(cell, withEntry: entry as! Entry)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            context.delete(trip?.entries?.allObjects[indexPath.row] as! NSManagedObject)
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withEntry entry: Entry) {
        cell.textLabel!.text = entry.title
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = segue.destination as! DetailViewController
                let entry = trip?.entries?.allObjects[indexPath.row]
                controller.entry = entry as? Entry
            }
        } else if segue.identifier == "toAddEntry" {
            let controller = segue.destination as! AddEntryViewController
            controller.trip = self.trip
        }
    }
    
}
