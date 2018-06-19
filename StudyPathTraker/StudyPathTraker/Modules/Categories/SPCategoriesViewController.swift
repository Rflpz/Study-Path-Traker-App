//
//  SPCategoriesViewController.swift
//  StudyPathTraker
//
//  Created by Rafael Lopez on 3/30/18.
//  Copyright © 2018 Jerti. All rights reserved.
//

import UIKit

class SPCategoriesViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties

    private var categories = [CategoryItem]()
    var flowLayout: SPCategoriesCollectionViewFlowDelegate?
    fileprivate var categoriesDataSource = SPCategoriesCollectionViewDataSource()
    var refreshControl = UIRefreshControl()
    var presenter: SPCategoryPresenter = SPCategoryPresenter()
    private var categorySelected: CategoryItem?

    // MARK: - View Controller LifeCycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setRefreshControl()
        setUpCollectionView()
        presenter.getCategories()
        loadCategories()
        categorySelected = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.delegate = self
        title = "Categories"
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(updateItem(longPressGestureRecognizer:)))
        self.view.addGestureRecognizer(longPressRecognizer)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newCategoryViewController = segue.destination  as? SPNewCategoryViewController {
            if categorySelected != nil {
                newCategoryViewController.isToEdit = true
                newCategoryViewController.category = categorySelected
            }
        }
        if let itemsViewController = segue.destination as? SPItemsViewController {
            itemsViewController.category = categorySelected
        }
    }

    // MARK: View Configuration
    
    func setRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Loading categories")
        refreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
    }

    private func setUpCollectionView() {
        let edgeInsects = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let configuration = CategoriesFlowConfiguration(categoryEdgeInsets: edgeInsects,
                                                        cellHeight: 165,
                                                        cellWidth: 140,
                                                        itemsPerRow: 2,
                                                        headerHeight: 10)
            flowLayout = SPCategoriesCollectionViewFlowDelegate(configuration: configuration)
        flowLayout?.selectedItemAction = { [weak self] index in
            self?.categorySelected = self?.categories[index]
            self?.performSegue(withIdentifier: Segues.CategoriesSegues.showItems.rawValue, sender: nil)
        }
        collectionView.dataSource = categoriesDataSource
        collectionView.delegate = flowLayout
    }

    @objc private func refreshList() {
        refreshControl.beginRefreshing()
        presenter.getCategories()
        loadCategories()
    }

    private func loadCategories() {
        categoriesDataSource.categories = categories
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }

    @objc func updateItem(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .began {
            let touchPoint = longPressGestureRecognizer.location(in: view)
            if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                categorySelected = categories[indexPath.row]
                performSegue(withIdentifier: Segues.CategoriesSegues.showAddCategory.rawValue, sender: nil)
            }
        }
    }

}
extension SPCategoriesViewController: SPCategoryPresenterProtocol {
    func didSuccessAction(_ message: String) {
        refreshList()
        showMessage(message)
    }

    func showError(_ message: String) {
        showMessage(message, title: "Error")
    }

    func show(categories: [CategoryItem]) {
        self.categories = categories
    }
}
