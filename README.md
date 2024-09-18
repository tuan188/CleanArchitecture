# iOS Clean Architecture

This project demonstrates the implementation of a repository list using Clean Architecture, MVVM, and Combine in Swift.

## Table of Contents

- [Clean Architecture](#ios-clean-architecture)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Installation](#installation)
  - [Architecture](#architecture)
    - [Domain Layer](#domain-layer)
    - [Data Layer](#data-layer)
    - [UI Layer](#ui-layer)
  - [Dependency Injection](#dependency-injection)
  - [Unit Tests](#unit-tests)
  - [Xcode Template](#xcode-template)
  - [Conclusion](#conclusion)
  - [License](#license)
  - [Related](#related)
 
## Introduction

CleanArchitecture is an example application built to demonstrate the usage of Clean Architecture along with MVVM and Combine frameworks in Swift. The application fetches and displays a list of repositories from a remote API.

## Installation

To install the necessary files using Swift Package Manager, follow these steps:

1. Open your Xcode project.
2. Select `File` > `Add Packages...`
3. Enter the URL of this repository: `https://github.com/tuan188/CleanArchitecture`
4. Select the appropriate package options and add the package to your project.

Alternatively, you can add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/tuan188/CleanArchitecture", .upToNextMajor(from: "2.0.5"))   
]
```

## Architecture

The architecture is structured into three main layers:

1. **Data Layer**: Responsible for data retrieval and manipulation: Gateway Implementations + API (Network) + Database
2. **Domain Layer**: Contains business logic and use cases: Entities + Use Cases + Gateway Protocols
3. **UI/Presentation Layer**: Manages user interface and user interactions: ViewModels + ViewControllers/Views + Navigator

Each layer has a clear responsibility and communicates with other layers via protocols and Combine publishers.

<img width="600" alt="High Level Overview" src="images/high_level_overview.png">

**Dependency Direction**

<img width="500" alt="Dependency Direction" src="images/dependency_direction.png">


### Domain Layer

The Domain Layer contains the application’s business logic and use cases.

<img width="500" alt="Domain Layer" src="images/domain.png">

#### Entities

Entities encapsulate enterprise-wide Critical Business Rules. An entity can be an object with methods, or it can be a set of data structures and functions. It doesn’t matter so long as the entities can be used by many different applications in the enterprise.
— Clean Architecture: A Craftsman’s Guide to Software Structure and Design (Robert C. Martin)

Entities are simple data structures:

```swift
struct Repo {
    var id: Int?
    var name: String?
    var fullname: String?
    var urlString: String?
    var starCount: Int?
    var folkCount: Int?
    var owner: Owner?
    
    struct Owner: Decodable {
        var avatarUrl: String?
        
        private enum CodingKeys: String, CodingKey {
            case avatarUrl = "avatar_url"
        }
    }
}
```

#### Use Cases

The software in the use cases layer contains application-specific business rules. It encapsulates and implements all of the use cases of the system. These use cases orchestrate the flow of data to and from the entities, and direct those entities to use their Critical Business Rules to achieve the goals of the use case.
— Clean Architecture: A Craftsman’s Guide to Software Structure and Design (Robert C. Martin)

UseCases are protocols which do one specific thing:

```swift
protocol GetRepoList {
    var repoGateway: RepoGatewayProtocol { get }
}

extension GetRepoList {
    func getRepos(dto: GetPageDto) -> AnyPublisher<PagingInfo<Repo>, Error> {
        repoGateway.getRepos(dto: dto)
    }
}
```

#### Gateway Protocols

Generally gateway is just another abstraction that will hide the actual implementation behind, similarly to the Facade Pattern. It could a Data Store (the Repository pattern), an API gateway, etc. Such as Database gateways will have methods to meet the demands of an application. However do not try to hide complex business rules behind such gateways. All queries to the database should relatively simple like CRUD operations, of course some filtering is also acceptable. - [Source](https://crosp.net/blog/software-architecture/clean-architecture-part-2-the-clean-architecture/)

```swift
protocol RepoGatewayProtocol {
    func getRepos(page: Int, perPage: Int) -> AnyPublisher<PagingInfo<Repo>, Error>
}
```

_Note: For simplicity we put the Gateway protocols and implementations in the same files. In fact, Gateway protocols should be at the Domain Layer and implementations at the Data Layer._

### Data Layer

<img width="500" alt="Data Layer" src="images/data.png">

The Data Layer is responsible for fetching data from the network and decoding it into usable models. It contains Gateway Implementations and one or many Data Stores. Gateways are responsible for coordinating data from different Data Stores. Data Store can be Remote or Local (for example persistent database). Data Layer depends only on the Domain Layer.

#### Gateway Implementations

```swift
struct RepoGateway: RepoGatewayProtocol {
    private struct GetReposResult: Decodable {
        var items = [Repo]()
    }
    
    func getRepos(page: Int, perPage: Int) -> AnyPublisher<PagingInfo<Repo>, Error> {
        APIServices.default
            .request(GitEndpoint.repos(page: page, perPage: perPage))
            .data(type: GetReposResult.self)
            .map { $0.items }
            .map { PagingInfo(page: page, items: $0) }
            .eraseToAnyPublisher()
    }
}
```

### UI Layer

The UI Layer is responsible for presenting data to the user and handling user interactions.

<img width="500" alt="Presentation Layer" src="images/presentation.png">


#### ViewModel

* ViewModel is the main point of MVVM application. The primary responsibility of the ViewModel is to provide data to the view, so that view can put that data on the screen.
* It also allows the user to interact with data and change the data.
* The other key responsibility of a ViewModel is to encapsulate the interaction logic for a view, but it does not mean that all of the logic of the application should go into ViewModel.
* It should be able to handle the appropriate sequencing of calls to make the right thing happen based on user or any changes on the view.
* ViewModel should also manage any navigation logic like deciding when it is time to navigate to a different view.
[Source](https://www.tutorialspoint.com/mvvm/mvvm_responsibilities.htm)

ViewModel performs pure transformation of a user Input to the Output:

```swift
public protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output
}
```

```swift
class ReposViewModel: GetRepoList, ShowRepoDetail {
    var repoGateway: RepoGatewayProtocol
    
    init(repoGateway: RepoGatewayProtocol) {
        self.repoGateway = repoGateway
    }
    
    // MARK: - Use cases
    
    func getRepos(page: Int) -> AnyPublisher<PagingInfo<Repo>, Error> {
        return getRepos(page: page, perPage: 10)
    }
    
    // // MARK: - Navigation
    
    func vm_showRepoDetail(repo: Repo) {
        showRepoDetail(repo: repo)
    }
}

// MARK: - ViewModel
extension ReposViewModel: ObservableObject, ViewModel {
    struct Input {
        let loadTrigger: AnyPublisher<Void, Never>
        let reloadTrigger: AnyPublisher<Void, Never>
        let loadMoreTrigger: AnyPublisher<Void, Never>
        let selectRepoTrigger: AnyPublisher<IndexPath, Never>
    }
    
    final class Output: ObservableObject {
        @Published var repos = [RepoItemViewModel]()
        @Published var isLoading = false
        @Published var isReloading = false
        @Published var isLoadingMore = false
        @Published var alert = AlertMessage()
        @Published var isEmpty = false
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let output = Output()
        
        let config = PageFetchConfig(initialLoadTrigger: input.loadTrigger,
                                     reloadTrigger: input.reloadTrigger,
                                     loadMoreTrigger: input.loadMoreTrigger,
                                     fetchItems: getRepos)
        
        let (page, error, isLoading, isReloading, isLoadingMore) = fetchPage(config: config).destructured

        page
            .map { $0.items.map(RepoItemViewModel.init) }
            .assign(to: \.repos, on: output)
            .store(in: cancelBag)
        
        input.selectRepoTrigger
            .handleEvents(receiveOutput: { [unowned self] indexPath in
                let repo = config.pageSubject.value.items[indexPath.row]
                self.vm_showRepoDetail(repo: repo)
            })
            .sink()
            .store(in: cancelBag)
        
        error
            .receive(on: RunLoop.main)
            .map { AlertMessage(error: $0) }
            .assign(to: \.alert, on: output)
            .store(in: cancelBag)
        
        isLoading
            .assign(to: \.isLoading, on: output)
            .store(in: cancelBag)
        
        isReloading
            .assign(to: \.isReloading, on: output)
            .store(in: cancelBag)
        
        isLoadingMore
            .assign(to: \.isLoadingMore, on: output)
            .store(in: cancelBag)
        
        return output
    }
}
```

## Dependency Injection

A ViewModel can be injected into a ViewController via property injection or initializer. Here is how the dependency injection is set up using [Factory](https://github.com/hmlongco/Factory).

```swift
import Factory

extension Container {
    func reposViewController(navigationController: UINavigationController) -> Factory<ReposViewController> {
        Factory(self) {
            let vc = ReposViewController.instantiate()
            let vm = ReposViewModel(repoGateway: self.repoGateway())
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
```

## Unit Tests

### What to test?

Unit tests are crucial for verifying the functionality and reliability of your application. In this architecture, we can test Use Cases, ViewModels, and Entities (if they contain business logic).

#### Use Case Tests

```swift
@testable import CleanArchitecture
import XCTest

final class LogInTests: XCTestCase, LogIn {
    var authGateway: AuthGatewayProtocol {
        return authGatewayMock
    }
    
    private var authGatewayMock = MockAuthGateway()
    private var cancelBag: CancelBag!

    override func setUpWithError() throws {
        cancelBag = CancelBag()
    }
    
    func test_login() {
        let result = expectValue(of: self.login(username: "username", password: "password"),
                                 equals: [ { _ in true } ])
        wait(for: [result.expectation], timeout: 1)
    }
    
    func test_login_failed() {
        authGatewayMock.loginReturnValue = .failure(TestError())
        
        let result = expectFailure(of: self.login(username: "user", password: "password"))
        wait(for: [result.expectation], timeout: 1)
    }
}
```

#### ViewModel Tests

```swift
import XCTest
import Combine

final class ReposViewModelTests: XCTestCase {
    private var viewModel: TestReposViewModel!
    private var cancelBag = CancelBag()
    private var output: ReposViewModel.Output!
    
    private var loadTrigger = PassthroughSubject<Void, Never>()
    private var reloadTrigger = PassthroughSubject<Void, Never>()
    private var loadMoreTrigger = PassthroughSubject<Void, Never>()
    private var selectRepoTrigger = PassthroughSubject<IndexPath, Never>()

    override func setUpWithError() throws {
        viewModel = TestReposViewModel(repoGateway: RepoGatewayFake())
        cancelBag = CancelBag()
        
        let input = ReposViewModel.Input(
            loadTrigger: loadTrigger.eraseToAnyPublisher(),
            reloadTrigger: reloadTrigger.eraseToAnyPublisher(),
            loadMoreTrigger: loadMoreTrigger.eraseToAnyPublisher(),
            selectRepoTrigger: selectRepoTrigger.eraseToAnyPublisher()
        )
        
        output = viewModel.transform(input, cancelBag: cancelBag)
    }
    
    func test_loadTrigger_getRepos() {
        // Act
        loadTrigger.send(())
        
        // Assert
        wait {
            XCTAssert(self.viewModel.getReposCalled)
            XCTAssertEqual(self.output.repos.count, 1)
        }
    }
}

final class TestReposViewModel: ReposViewModel {
    var vmShowRepoDetailCalled = false
    var getReposCalled = false
    var getReposReturnValue: Result<PagingInfo<Repo>, Error> = .success(PagingInfo.fake)
    
    override func vm_showRepoDetail(repo: Repo) {
        vmShowRepoDetailCalled = true
    }
    
    override func getRepos(page: Int) -> AnyPublisher<PagingInfo<Repo>, Error> {
        getReposCalled = true
        return getReposReturnValue.publisher.eraseToAnyPublisher()
    }
}
```

## Project Folder and File Structure

```
- /CleanArchitecture    
    - /Domain
        - /UseCases
            - /Product
                - GetProductList.swift
                - UpdateProduct.swift
                - DeleteProduct.swift
                ...
            - /Login
            - /App
            - /User
            - /Repo
        - /Entities
            - Product.swift
            - User.swift
            - Repo.swift
    - /Data
        - /Gateways
            - RepoGateway.swift
            - UserGateway.swift
            - AppGateway.swift
            ...
        - /UserDefaults
            - AppSettings.swift
        - /API
            - API+Product.swift
            - API+Repo.swift
        - /CoreData
            - UserRepository.swift
    - /Scenes
        - /App
        - /Main
        - /Login
        - /UserList
        - /Products
        ...
    - /Config
        - APIUrls.swift
    	- Notifications.swift
    - /Support
        - /Extension
            - UIViewController+.swift
            - UITableView+.swift
            ...
        - Utils.swift
    - /Resources
        - /Assets.xcassets
    - AppDelegate.swift
    - ...

- /CleanArchitectureTests
    - /Domain
    - /Data
    - /Scenes
```

## Xcode Template

* [Import Clean Architecture File Templates for Xcode](xcode_templates.md)
* [Import Clean Architecture Project Template for Xcode](xcode_project_template.md)

## Conclusion

CleanArchitecture demonstrates the implementation of Clean Architecture, MVVM, and Combine in a Swift application. The architecture separates concerns into distinct layers, making the codebase more maintainable, testable, and scalable. By following these principles, you can build robust applications that are easy to extend and adapt to changing requirements.

Feel free to explore the code and adapt the architecture to your needs. Contributions and feedback are welcome!

## License

`CleanArchitecture` is available under the MIT license. See the [LICENSE](LICENSE) file for more information.

## Related
* [APIService](https://github.com/sun-asterisk/tech-standard-ios-api)
* [Clean Architecture (RxSwift + UIKit)](https://github.com/tuan188/MGCleanArchitecture)
