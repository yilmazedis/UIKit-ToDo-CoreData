//
//  ViewController.swift
//  Todo-CoreData
//
//  Created by Yilmaz Edis (employee ID: y84185251) on 7.12.2021.
//
import UIKit
import CoreData
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [Item]()

    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }

    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour {
            if let navBarColour = UIColor(hexString: colourHex) {
                let titleColour = ContrastColorOf(navBarColour, returnFlat: true)
                let title = selectedCategory!.name

                configureNavigationBar(largeTitleColor: titleColour, backgoundColor: navBarColour, tintColor: titleColour, title: title!, preferredLargeTitle: true)

                searchBar.barTintColor = navBarColour
            }
        }
    }

    //MARK: - Tableview Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let item = itemArray[indexPath.row]

        cell.textLabel?.text = item.title
        if let colour = UIColor(hexString: selectedCategory!.colour!)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count)) {
            cell.backgroundColor = colour
            cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
        }
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }

    //MARK: - TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)

        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        saveItems()

        tableView.deselectRow(at: indexPath, animated: true)

    }

    //MARK: - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {


           var textField = UITextField()

           let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

           let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
               //what will happen once the user clicks the Add Item button on our UIAlert


               let newItem = Item(context: self.context)
               newItem.title = textField.text!
               newItem.done = false
               newItem.date = Date()
               newItem.parentCategory = self.selectedCategory
               self.itemArray.append(newItem)

               self.saveItems()
           }

           alert.addTextField { (alertTextField) in
               alertTextField.placeholder = "Create new item"
               textField = alertTextField

           }


           alert.addAction(action)

           present(alert, animated: true, completion: nil)

       
    }


    //MARK - Model Manupulation Methods

    func saveItems() {

        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }

        self.tableView.reloadData()
    }

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }


        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }

        tableView.reloadData()

    }

    //Mark: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
    }

}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let request : NSFetchRequest<Item> = Item.fetchRequest()

        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        loadItems(with: request, predicate: predicate)

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}








