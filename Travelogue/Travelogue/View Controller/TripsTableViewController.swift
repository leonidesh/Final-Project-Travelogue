//
//  TripsTableViewController.swift
//  Travelogue
//
//  Created by 刘洋 on 7/23/19.
//  Copyright © 2019 Yang Liu. All rights reserved.
//
import UIKit
import CoreData

class TripsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        
        // Initialize the alert controller with input text field
        var inputTextField: UITextField = UITextField();
        let alert = UIAlertController.init(title: "New Trip", message: "Input your destination: ", preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "OK", style:.default) { (action: UIAlertAction) ->() in
            let newTrip = Trip(context: context)
            newTrip.destination = inputTextField.text
        }
        let cancel = UIAlertAction.init(title: "Cancel", style:.cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.addTextField { (textField) in
            inputTextField = textField
        }
        self.present(alert, animated: true, completion: nil)
        
        // Save the context
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Trip Cell", for: indexPath)
        let trip = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withTrip: trip)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "Attention!", message: "Are you sure to delete the trip? The operation might be destrucive and can not be recovered!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                let context = self.fetchedResultsController.managedObjectContext
                context.delete(self.fetchedResultsController.object(at: indexPath))
                
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            })
            alertController.addAction(deleteAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withTrip trip: Trip) {
        cell.textLabel!.text = trip.destination
    }
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Trip> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "destination", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "Trip")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Trip>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withTrip: anObject as! Trip)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withTrip: anObject as! Trip)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEntries" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = segue.destination as! TripEntriesTableViewController
                let object = fetchedResultsController.object(at: indexPath)
                controller.trip = object
                controller.title = object.destination
            }
        }
    }
    
}
