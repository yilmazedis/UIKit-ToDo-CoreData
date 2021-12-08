//
//  CategoryViewController.swift
//  Todo-CoreData
//
//  Created by Yilmaz Edis (employee ID: y84185251) on 7.12.2021.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    var categories = [Category]()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()

    }
    override func viewWillAppear(_ animated: Bool) {
        let backgoundColor = UIColor(hexString: "#1D9BF6")
        let titleColour = ContrastColorOf(backgoundColor!, returnFlat: true)

        configureNavigationBar(largeTitleColor: titleColour, backgoundColor: backgoundColor!, tintColor: titleColour, title: "ToDo", preferredLargeTitle: true)
    }

    //MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categories.count

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name

        let category = categories[indexPath.row]
        guard let categoryColour = UIColor(hexString: category.colour!) else {fatalError()}
        cell.backgroundColor = categoryColour
        cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)


        return cell

    }


    //MARK: - TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController

        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }

    //MARK: - Data Manipulation Methods

    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }

        tableView.reloadData()

    }

    func loadCategories() {

        let request : NSFetchRequest<Category> = Category.fetchRequest()

        do{
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }

        tableView.reloadData()

    }

    //Mark: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        context.delete(categories[indexPath.row])
        categories.remove(at: indexPath.row)
    }


    //MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add", style: .default) { (action) in

            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()

            self.categories.append(newCategory)

            self.saveCategories()

        }

        alert.addAction(action)

        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }

        present(alert, animated: true, completion: nil)

    }





}
