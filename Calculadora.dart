import 'dart:io';
import 'dart:math';


double calcularExpressao(String expressao) {

  expressao = expressao.replaceAll(' ', '');
  
  return _avaliarExpressao(expressao);
}

double _avaliarExpressao(String expressao) {

  while (expressao.contains('(')) {
    int start = expressao.lastIndexOf('(');
    int end = expressao.indexOf(')', start);
    
    if (end == -1) {
      throw FormatException('Parênteses desbalanceados');
    }
    
    String subExpr = expressao.substring(start + 1, end);
    double subResult = _avaliarExpressao(subExpr);
    expressao = expressao.substring(0, start) + 
                subResult.toString() + 
                expressao.substring(end + 1);
  }
  
  expressao = _resolverOperacao(expressao, '^', (a, b) => pow(a, b).toDouble());
  
  expressao = _resolverOperacao(expressao, '*', (a, b) => a * b);
  expressao = _resolverOperacao(expressao, '/', (a, b) {
    if (b == 0) throw Exception('Erro: Divisão por zero não é permitida');
    return a / b;
  });
  
  expressao = _resolverOperacao(expressao, '+', (a, b) => a + b);
  expressao = _resolverOperacao(expressao, '-', (a, b) => a - b);
  
  return double.parse(expressao);
}

String _resolverOperacao(String expressao, String operador, double Function(double, double) operacao) {
  List<String> tokens = _tokenizar(expressao);
  List<String> resultado = [];
  
  if (tokens.isNotEmpty && tokens[0] == '-') {
    resultado.add('-');
    tokens.removeAt(0);
  }
  
  int i = 0;
  while (i < tokens.length) {
    if (tokens[i] == operador && i + 1 < tokens.length) {
      double operandoEsquerdo = double.parse(resultado.removeLast());
      double operandoDireito = double.parse(tokens[i + 1]);
      double resultadoOperacao = operacao(operandoEsquerdo, operandoDireito);
      resultado.add(resultadoOperacao.toString());
      i += 2;
    } else {
      resultado.add(tokens[i]);
      i++;
    }
  }
  
  return resultado.join('');
}

List<String> _tokenizar(String expressao) {
  List<String> tokens = [];
  String atual = '';
  
  for (int i = 0; i < expressao.length; i++) {
    String char = expressao[i];
    
    if ('+-*/^'.contains(char)) {
      if (atual.isNotEmpty) {
        tokens.add(atual);
        atual = '';
      }
      if (char == '-' && (tokens.isEmpty || '+-*/^('.contains(tokens.last))) {
        atual += char;
      } else {
        tokens.add(char);
      }
    } else {
      atual += char;
    }
  }
  
  if (atual.isNotEmpty) {
    tokens.add(atual);
  }
  
  return tokens;
}

void main() {
  print('Operações suportadas: + - * / ^ ( )');
  print('Exemplos: 2+2, 5*3+1, (2+3)*4, 2^3+5');
  print('Digite "sair" para encerrar');
  print('');
  
  while (true) {
    stdout.write('Digite a operação: ');
    String? input = stdin.readLineSync();
    
    if (input == null || input.toLowerCase() == 'sair') {
      print('\n👋 Encerrando a calculadora...');
      break;
    }
    
    if (input.trim().isEmpty) {
      print('⚠️  Por favor, digite uma operação válida.');
      continue;
    }
    
    try {
      double resultado = calcularExpressao(input);
      
      String resultadoFormatado = resultado == resultado.toInt() 
          ? resultado.toInt().toString() 
          : resultado.toStringAsFixed(2);
      
      print('✅ Resultado: $resultadoFormatado\n');
      
    } catch (e) {
      print('❌ Erro: Expressão inválida. Tente novamente.\n');
    }
  }

}
