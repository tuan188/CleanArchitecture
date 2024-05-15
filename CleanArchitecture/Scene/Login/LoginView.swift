//
//  LoginView.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/29/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import SwiftUI
import Combine
import Factory

struct LoginView: View {
    @ObservedObject var input: LoginViewModel.Input
    @ObservedObject var output: LoginViewModel.Output
    @ObservedObject var viewModel: LoginViewModel
    
    private let cancelBag = CancelBag()
    private let loginTrigger = PassthroughSubject<Void, Never>()
    
    var body: some View {
        LoadingView(isShowing: $output.isLoading, text: .constant("")) {
            VStack(alignment: .leading) {
                Text("User name:")
                TextField("", text: self.$input.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text(self.output.usernameValidationMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                Text("Password:")
                    .padding(.top)
                SecureField("", text: self.$input.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text(self.output.passwordValidationMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                HStack {
                    Spacer()
                    Button("Login") {
                        self.loginTrigger.send(())
                    }
                    .disabled(!self.output.isLoginEnabled)
                    .padding(.top)
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
        .alert(isPresented: $output.alert.isShowing) {
            Alert(
                title: Text(output.alert.title),
                message: Text(output.alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    init(viewModel: LoginViewModel) {
        let input = LoginViewModel.Input(loginTrigger: loginTrigger.asDriver())
        output = viewModel.transform(input, cancelBag: cancelBag)
        self.viewModel = viewModel
        self.input = input
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel(authGateway: Container.shared.previewAuthGateway()))
    }
}

extension Container {
    func loginView(navigationController: UINavigationController) -> Factory<LoginView> {
        Factory(self) {
            LoginView(viewModel: LoginViewModel(authGateway: self.authGateway()))
        }
    }
}
