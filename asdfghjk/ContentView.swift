import Foundation

struct Question {
    let text: String
    let answers: [String]
    let correctAnswerIndex: Int
    let money: Int
}

class MilionerzyModel {
    private let questions: [Question] = [
        Question(text: "Pytanie 1", answers: ["Odpowiedź A", "Odpowiedź B", "Odpowiedź C", "Odpowiedź D"], correctAnswerIndex: 0, money: 100),
    ]
    
    private(set) var currentQuestionIndex = 0
    private(set) var totalMoney = 0
    private(set) var lives = 3
    
    var currentQuestion: Question {
        return questions[currentQuestionIndex]
    }
    
    func checkAnswer(_ selectedAnswerIndex: Int) {
        if selectedAnswerIndex == currentQuestion.correctAnswerIndex {
            totalMoney += currentQuestion.money
        } else {
            lives -= 1
        }
        
        if currentQuestionIndex + 1 < questions.count && lives > 0 {
            currentQuestionIndex += 1
        } else {
            currentQuestionIndex = 0
        }
    }
}



import SwiftUI

class MilionerzyViewModel: ObservableObject {
    @Published var milionerzyModel = MilionerzyModel()
    @Published var showWelcome = true
    @Published var showCongratulations = false
    @Published var showGameOver = false
    
    var currentQuestion: Question {
        return milionerzyModel.currentQuestion
    }
    
    var totalMoney: Int {
        return milionerzyModel.totalMoney
    }
    
    var lives: Int {
        return milionerzyModel.lives
    }
    
    func startGame() {
        showWelcome = false
    }
    
    func checkAnswer(_ selectedAnswerIndex: Int) {
        milionerzyModel.checkAnswer(selectedAnswerIndex)
        
        if milionerzyModel.lives > 0 && milionerzyModel.currentQuestionIndex < milionerzyModel.questions.count {
        } else {
            if milionerzyModel.lives == 0 {
                showGameOver = true
            } else {
                showCongratulations = true
            }
        }
    }
    
    func resetGame() {
        milionerzyModel = MilionerzyModel()
        showWelcome = true
        showCongratulations = false
        showGameOver = false
    }
}



import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: MilionerzyViewModel

    var body: some View {
        VStack {
            if viewModel.showWelcome {
                WelcomeView(viewModel: viewModel)
            } else {
                HStack {
                    VStack(alignment: .leading) {
                        QuestionView(viewModel: viewModel)
                        ForEach(0..<viewModel.currentQuestion.answers.count, id: \.self) { index in
                            AnswerButtonView(answerText: viewModel.currentQuestion.answers[index]) {
                                viewModel.checkAnswer(index)
                            }
                            .padding(.bottom, 8)
                        }
                    }
                    .padding()
                    LadderView(
                        lives: viewModel.milionerzyModel.lives,
                        questions: viewModel.milionerzyModel.questions,
                        currentQuestionIndex: viewModel.milionerzyModel.currentQuestionIndex
                    )
                    .padding()
                }
            }

            if viewModel.showCongratulations {
                Text("Gratulacje! Poprawna odpowiedź! Zdobyłeś \(viewModel.currentQuestion.money) zł.")
                    .foregroundColor(.green)
                    .font(.headline)
                    .padding()
            }

            
            NavigationLink(destination: GameOverView(viewModel: viewModel), isActive: $viewModel.showGameOver) {
                EmptyView()
            }
        }
    }
}


import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: MilionerzyViewModel

    var body: some View {
        VStack {
            Text("Witaj w Milionerach!")
                .font(.largeTitle)
                .padding()

            Button("Rozpocznij grę") {
                viewModel.startGame()
            }
            .buttonStyle(StartButtonStyle())
            .padding()
        }
    }
}

struct StartButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(viewModel: MilionerzyViewModel())
    }
}


import SwiftUI

struct QuestionView: View {
    @ObservedObject var viewModel: MilionerzyViewModel

    var body: some View {
        Text(viewModel.currentQuestion.text)
            .font(.title)
            .padding()
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView(viewModel: MilionerzyViewModel())
    }
}


import SwiftUI

struct AnswerButtonView: View {
    let answerText: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(answerText)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
}

struct AnswerButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AnswerButtonView(answerText: "Odpowiedź A", action: {})
    }
}


import SwiftUI

struct LadderView: View {
    let lives: Int
    let questions: [Question]
    let currentQuestionIndex: Int

    var body: some View {
        VStack {
            LivesView(lives: lives)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(questions.indices, id: \.self) { index in
                    LadderItemView(
                        questionNumber: index + 1,
                        money: questions[index].money,
                        isCurrent: index == currentQuestionIndex
                    )
                }
            }
        }
        .padding()
    }
}

struct LadderItemView: View {
    let questionNumber: Int
    let money: Int
    let isCurrent: Bool

    var body: some View {
        HStack {
            Text("\(questionNumber).")
                .foregroundColor(isCurrent ? .yellow : .white)

            Text("\(money) zł")
                .foregroundColor(isCurrent ? .yellow : .white)
        }
    }
}

struct LivesView: View {
    let lives: Int

    var body: some View {
        HStack {
            ForEach(0..<lives) { _ in
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

struct LadderView_Previews: PreviewProvider {
    static var previews: some View {
        LadderView(lives: 3, questions: [], currentQuestionIndex: 0)
    }
}

