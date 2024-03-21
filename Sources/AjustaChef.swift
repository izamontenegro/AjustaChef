import ArgumentParser
import Foundation

struct NomeEQuantidadeIngrediente: Codable {
    let qtd: Double
    let ingrediente: String
}

func imprimirReceitaOriginal(receita: [NomeEQuantidadeIngrediente]) -> ([Double]) {
    print("\n")
    print("""
    ╔═╗ ┬┬ ┬┌─┐┌┬┐┌─┐╔═╗┬ ┬┌─┐┌─┐
    ╠═╣ ││ │└─┐ │ ├─┤║  ├─┤├┤ ├┤
    ╩ ╩└┘└─┘└─┘ ┴ ┴ ┴╚═╝┴ ┴└─┘└
""")
    
    print("\n----------------------------------------------\n")

    var quantidades: [Double] = []
    
    print("Receita original: ")
    for i in 0...receita.count - 1 {
        quantidades.append(receita[i].qtd)
        print("\(i+1). \(quantidades[i]) de \(receita[i].ingrediente)")
    }
    return quantidades
}

func verbosePrint(_ text: String, verbose: BooleanLiteralType) {
    if verbose == true {
        print(text)
        sleep(1)
    }
}

@main
struct AjustaChef: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "Ingredient Adjustment Calculator.",
        discussion: "This tool was developed to assist amateur cooks in adjusting the proportion of ingredients in their recipes. By inputting a txt file with the list of recipe items and informing the ingredient with a different quantity from the original recipe, the calculator will return an adapted recipe according to the selected subcommand. The best thing about this application is the possibility of making countless recipes without being restricted by the number of ingredients.",
        subcommands: [
            Diminuir.self,
            Aumentar.self,
            Ajustar.self
        ]
    )
        
}

struct Ajustar: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "Adjust the recipe based on the quantity of one ingredient."
    )
    
    @Argument(help: "Name of the input file.")
       var inputFile: String
    
    @Flag(name: .shortAndLong, help: "Demonstrates the process of recipe adaptation.")
    var verbose = false
    
    @Argument(help: "Ingredient name with a different quantity than the original recipe.")
    var reducedItem: String
    
    @Argument(help: "Reduced amount of the ingredient.")
    var reducedQuantity: Double
    
    func run() throws {
        let url = Bundle.module.url(forResource: "receitas", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let receita = try JSONDecoder().decode([NomeEQuantidadeIngrediente].self, from: data)
        
        let quantidades = imprimirReceitaOriginal(receita: receita)
        var posicaoDoReduzido: Int = 0
        var qtdAjustada: [Double] = []
        var ingredientes: [String] = []
        
        let input = try? String(contentsOfFile: inputFile)
        
                // Separando números e palavras
                let receita = input.components(separatedBy: .whitespacesAndNewlines)
                    .flatMap { $0.components(separatedBy: CharacterSet.alphanumerics.inverted) }
                    .filter { !$0.isEmpty }

                // Separando números e palavras
                var numbers = [String]()
                var words = [String]()
                for element in wordsAndNumbers {
                    if let _ = Int(element) {
                        numbers.append(element)
                    } else {
                        words.append(element)
                    }
                }
    
        
        print("\n")
        //Encontrando a posição do item reduzido no vetor da receita
        if  reducedQuantity == 0 {
            print("Com a quantidade informada do ingrediente \(reducedItem), não é possível ajustar a receita.\n")
        } else {
            for(i, item) in receita.enumerated() where item.ingrediente == reducedItem { posicaoDoReduzido = i}
            
            //Calculando quantidades adaptadas
            for i in 0...receita.count - 1 {
                qtdAjustada.append((reducedQuantity * quantidades[i])/quantidades[posicaoDoReduzido])
            }
            
            verbosePrint("- Calculando os novos valores...", verbose: verbose)
            verbosePrint("- Adicionando as novas quantidades na receita...", verbose: verbose)
            
            print("\n\n👩🏽‍🍳 Receita ajustada para apenas \(reducedQuantity) \(reducedItem):")
            for i in 0...receita.count - 1 {
                ingredientes.append(receita[i].ingrediente)
                let numeroComDuasCasas = Double(Int(qtdAjustada[i]*100))/100
                print("\(i+1). \(numeroComDuasCasas) de \(ingredientes[i])")
                sleep(1)
            }
        }
        print("\n----------------------------------------------\n")
    }
}

struct Aumentar: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "Increase the recipe by a factor of x."
    )
    @Flag(name: .shortAndLong, help: "Shows the process of recipe adaptation.")
    var verbose = false
    
    @Argument(help: "How many times it will be increased.")
    var increasedQuantity: Double
    
    func run() throws {
        
        let url = Bundle.module.url(forResource: "receitas", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let receita = try JSONDecoder().decode([NomeEQuantidadeIngrediente].self, from: data)
        
        var quantidades = imprimirReceitaOriginal(receita: receita)
        var ingredientes: [String] = []
        
        print("\n")
        verbosePrint("- Multiplicando cada ingrediente por \(increasedQuantity)...", verbose: verbose)
        verbosePrint("- Adicionando as novas quantidades na receita...", verbose: verbose)
        print("\n\n👩🏽‍🍳 Receita aumentada em \(increasedQuantity) vezes:")
        
        for i in 0...receita.count - 1 {
            ingredientes.append(receita[i].ingrediente)
            quantidades[i] = (increasedQuantity * quantidades[i])
            let numeroComDuasCasas = Double(Int(quantidades[i]*100))/100
            print("\(i+1). \(numeroComDuasCasas) de \(ingredientes[i])")
            sleep(1)
        }
        print("\n----------------------------------------------\n")
    }
}

struct Diminuir: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "Decrease the recipe by a factor of x."
    )
    
    @Flag(name: .shortAndLong, help: "Shows the recipe adaptation process.")
    var verbose = false
    
    func verbosePrint(_ text: String) {
        if verbose == true {
            print(text)
            sleep(1)
        }
    }
    
    @Argument(help: "How many times it will be reduced.")
    var reducedQuantity: Double
    
    func run() throws {
        
        let url = Bundle.module.url(forResource: "receitas", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let receita = try JSONDecoder().decode([NomeEQuantidadeIngrediente].self, from: data)
        
        var quantidades = imprimirReceitaOriginal(receita: receita)
        var ingredientes: [String] = []
        
        print("\n")
        verbosePrint("- Dividindo todos os ingredientes por \(reducedQuantity)...")
        verbosePrint("- Adicionando as novas quantidades na receita...")
        print("\n\n👩🏽‍🍳 Receita reduzida em \(reducedQuantity) vezes:")
        
        for i in 0...receita.count - 1 {
            ingredientes.append(receita[i].ingrediente)
            quantidades[i] = (quantidades[i] / reducedQuantity)
            let numeroComDuasCasas = Double(Int(quantidades[i]*100))/100
            print("\(i+1). \(numeroComDuasCasas) de \(ingredientes[i])")
            sleep(1)
        }
        print("\n----------------------------------------------\n")
    }
}
